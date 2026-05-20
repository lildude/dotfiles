# Example: Correlating Sentry exceptions with Splunk

## Scenario

You found a timeout exception in Sentry but want to understand the full request context — what happened before the timeout, how long the request took, and whether it's an isolated incident or widespread.

## Prompt

```
I'm seeing ActiveRecord::ConnectionTimeoutError in Sentry for the IssuesController. Can you check how widespread it is and correlate with Splunk?
```

## Investigation Flow

### 1. Search Sentry for the exception

```
Find issues matching "ActiveRecord::ConnectionTimeoutError" in the heaven project, scoped to controller:"IssuesController"
```

### 2. Check tag distribution

```
Get tag values for HEAVEN-56789 — show me the environment and URL breakdown
```

### 3. Cross-reference with Splunk for volume

Sentry rate-limits at 300 req/s per project. For true volume, check Splunk:

```spl
index=prod-exceptions catalog_service="github/issues" exception_type="ActiveRecord::ConnectionTimeoutError"
| stats count by rails.controller.action
| sort -count
```

### 4. Find a specific request in both systems

Grab a request ID from Sentry breadcrumbs, then look it up in Splunk:

```spl
index=rails request_id="FA42:EA6B:A4E866:BEF346:602F81B9"
```

## Expected Output

```markdown
## Error Investigation: ActiveRecord::ConnectionTimeoutError — IssuesController

**Sentry Issue**: [HEAVEN-56789](https://github.sentry.io/issues/56789/)
**First seen**: 2026-03-12 10:15 UTC | **Events**: 1,247 (Sentry) / 3,891 (Splunk)

### Why the numbers differ
Sentry shows 1,247 events but Splunk shows 3,891 — Sentry is rate-limiting
this project at 300 req/s. The `failbotg.app.needles` Datadog metric confirms
~3,900 exceptions in this window.

### Distribution (from Sentry tags)
- **Actions**: show (78%), index (15%), update (7%)
- **Environments**: production only (not canary)

### Splunk Cross-Reference
- [Exception volume by action](https://splunk.githubapp.com/en-US/app/search/search?q=...)
- [Request logs for sample request](https://splunk.githubapp.com/en-US/app/search/search?q=...)

### Root Cause
Connection pool saturation on the issues-pull-requests cluster during
peak traffic (12:00-14:00 UTC).
```
