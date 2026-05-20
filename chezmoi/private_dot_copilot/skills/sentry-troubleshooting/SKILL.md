---
name: sentry-troubleshooting
description: This skill should be used when the user asks to "investigate Sentry errors", "find exceptions", "debug error spikes", "check release regressions", "get stack traces from Sentry", "analyze Sentry issue", or needs to triage production errors tracked in Sentry
version: 1.0.0
---

# Sentry Troubleshooting

You are an expert at investigating production errors using Sentry. You use the Sentry MCP server to search issues, analyze events, inspect stack traces, and identify release regressions.

## When to Use This Skill

- Triaging an error spike after a deploy
- Getting the full stack trace for a specific Sentry issue
- Finding new exceptions introduced by a release
- Checking how many users/environments are affected by an error
- Using AI root cause analysis (Seer) for complex issues
- Correlating Sentry exceptions with Splunk logs or Datadog traces

## Boundaries

**Will:**
- Search issues, events, and releases
- Get stack traces, breadcrumbs, and tag distributions
- Run AI root cause analysis with Seer
- Correlate errors with other observability tools
- Produce structured investigation reports

**Will not:**
- Resolve, ignore, or delete Sentry issues
- Modify alert rules or notification settings
- Create or configure Sentry projects
- Access issues you don't have Sentry permissions for

## Prerequisites

The Sentry MCP server must be configured. Add to `.vscode/mcp.json`:

```json
{
  "servers": {
    "sentry": {
      "type": "http",
      "url": "https://mcp.sentry.dev/mcp"
    }
  }
}
```

Sentry authenticates via browser OAuth on first use. No API key needed.

> **Fallback**: If the remote endpoint doesn't work, you can instead configure `.vscode/mcp.json` to use `mcp-remote`:
>
> ```json
> {
>   "servers": {
>     "sentry": {
>       "type": "stdio",
>       "command": "npx",
>       "args": ["-y", "mcp-remote@latest", "https://mcp.sentry.dev/mcp"]
>     }
>   }
> }
> ```

## Troubleshooting Methodology

### Step 1: Establish Scope

Determine what you're investigating:

1. **Error spike** → Start with `search_events` for aggregate counts
2. **Specific exception** → Start with `search_issues` by error type
3. **Release regression** → Start with `find_releases` then correlate
4. **Single issue** → Start with `get_issue_details` for the stack trace

Ask the user for:
- **Project or organization** scope
- **Time window** (last hour, last 24h, since deploy)
- **Error message or type** if known
- **Release version** if investigating a regression

### Step 2: Search and Triage

#### For error spikes (unknown cause)

Start broad with org-wide event counts, then narrow:

```
Count errors in the last 24 hours across all projects, grouped by project
```

Then drill into the worst project:

```
Search for the top issues in <project> from the last 24 hours
```

#### For known exception types

Search directly:

```
Find issues matching "ConnectionTimeoutError" in <project>
```

#### For release regressions

Find recent releases and look for new issues:

```
Find the last 5 releases for <project>
```

Then search for issues first seen after the deploy:

```
Search for new issues in <project> first seen after <release-date>
```

### Step 3: Deep Dive

Once you've identified a suspect issue:

1. **Get full details**: Use `get_issue_details` for stack trace, breadcrumbs, and context
2. **Check distribution**: Use `get_issue_tag_values` to understand scope (which environments, browsers, URLs)
3. **Check events**: Use `search_issue_events` to see individual occurrences and their payloads
4. **Trace context**: If a trace ID is available, use `get_trace_details` for the full distributed trace

### Step 4: Root Cause Analysis

For complex issues:

1. **Use Seer**: `analyze_issue_with_seer` provides AI-powered root cause analysis with code fix suggestions
2. **Check the stack trace**: Look for your application code frames (not library/framework frames)
3. **Check breadcrumbs**: Sentry records recent actions before the error — HTTP requests, DB queries, user actions
4. **Correlate with releases**: Was this introduced by a specific deploy?

### Step 5: Report Findings

Present findings in this format:

```markdown
## Error Investigation: <Title>

**Issue**: [PROJ-1234](link) — <error type>
**First seen**: <date> | **Events**: <count> | **Users affected**: <count>

### Stack Trace (key frames)
<application-relevant frames only>

### Root Cause
<explanation of what's happening>

### Impact
- Environments: <list>
- Affected endpoints/pages: <list>
- User impact: <description>

### Recommended Fix
<specific code change or configuration fix>

### Related
- Release: <version that introduced it>
- Related issues: <links>
```

## Common Investigation Patterns

### Pattern 1: Post-Deploy Error Spike

A deploy went out and errors increased:

1. `find_releases` → identify the release
2. `search_events` → compare error counts before/after deploy timestamp
3. `search_issues` → filter by `firstSeen` after deploy time
4. `get_issue_details` → stack trace for each new issue
5. `analyze_issue_with_seer` → AI fix suggestion

**Deploy monitoring traps to avoid:**
- The Sentry Release page (linked by Hubot) takes ~2 minutes to load after deploy starts. It doesn't auto-refresh.
- Sentry defaults to showing issues from the **last 14 days**. For rapid deploys, change to "Last hour" or "Last 24 hours" — otherwise you're drowning in pre-existing noise.
- "New" issues during your deploy aren't always yours. Sentry isn't perfect at distinguishing new vs existing. Filter by `firstSeen` after your deploy timestamp.
- Use the [Sentry firehose](https://sentry.io/github/github/) to check if pre-existing errors got *more frequent* (watch the graphs, click play for auto-reload).

### Pattern 2: Intermittent Timeout Errors

Users report timeouts but they're not consistent:

1. **Don't just search `heaven`** — GitHub has separate Sentry projects for perf:
   - `github-timeout` — requests that timed out
   - `github-killed-query` — SQL queries that were killed
   Search these with `controller` filters for your endpoint.
2. `search_issues` with "timeout" or "ConnectionError" in `heaven`
3. `get_issue_tag_values` → check if clustered by environment, region, or time
4. `search_issue_events` → look at individual events for patterns in request params
5. Check breadcrumbs for slow DB queries or external service calls preceding the timeout

**Slow request → stack trace workflow:**
Grab slow request IDs from Splunk, then look them up in Sentry for the full stack trace:
```spl
index=rails controller=IssuesController action=show elapsed>=8 | table request_id
```
Then in Sentry: `request_id:"FA42:EA6B:A4E866:BEF346:602F81B9"`

### Pattern 3: Error Rate Threshold Breach

An alert fired for error rate exceeding a threshold:

1. `search_events` → aggregate errors by type in the alert window
2. `search_issues` → find the specific exceptions driving the spike
3. `get_issue_details` → determine if it's a new error or an existing one that worsened
4. `get_issue_tag_values` → scope the blast radius

### Pattern 4: Correlating with Performance Data

When you have a slow endpoint and want to check for related errors:

1. `search_events` → count errors filtered by the URL/endpoint
2. `search_issues` → find exception types for that endpoint
3. Cross-reference with Datadog APM traces for the same time window

## Common Pitfalls

- **Empty results from `search_issues`**: Your Sentry role may lack project access. Use `search_events` at org scope as a fallback — aggregate queries work across all projects.
- **SSE endpoint is gone**: Sentry removed `/sse`. Use `/mcp` (Streamable HTTP). You'll get a 410 if you use the old endpoint.
- **Natural language queries are converted to Sentry syntax**: If results are empty, try broader terms or check the Sentry web UI directly.
- **Rate limits**: Sentry MCP has rate limits. If you hit them, wait a moment and retry with a more specific query.
- **Old issues vs new issues**: `firstSeen` tells you when Sentry first recorded the issue. `lastSeen` tells you when it last occurred. For regression hunting, filter on `firstSeen`.
- **Sentry groups by stack trace, not root cause**: The same root cause can appear as multiple Sentry issues if the call path varies. Count *events*, not *issues*, when assessing volume.
- **Missing `catalog_service` on exceptions**: This means the controller namespace isn't mapped in [ServiceMapping middleware](https://github.com/github/github/blob/master/lib/github/service_mapping.rb). Fix by adding the mapping, or manually tag with `Failbot.report(e, catalog_service: "my-service")`.
- **Large shared projects hit rate limits fast**: If your exceptions are in `github` or `github-user` (shared by many services), consider routing to a separate Sentry project by setting the `app` key in your Failbot context. This gives you your own 300 req/s budget.
- **Sentry counts are incomplete during spikes**: When rate-limited, Sentry drops events silently. For true volume, check Splunk's `prod-exceptions` index (failbotg delivers *everything*) or the `failbotg.app.needles` Datadog metric.

## Validation Checklist

Before reporting findings:

- [ ] Confirmed the error is from production (not staging/dev)
- [ ] Checked event count and trend (growing, stable, or resolved?)
- [ ] Identified affected users/environments scope
- [ ] Got a stack trace with application code frames
- [ ] Checked if the error correlates with a recent release
- [ ] Provided a specific, actionable fix recommendation

## References

- [Sentry MCP documentation](https://docs.sentry.io/product/integrations/mcp/)
- [Sentry search syntax](https://docs.sentry.io/product/sentry-basics/search/)
- [Sentry Seer AI analysis](https://docs.sentry.io/product/issues/issue-details/seer/)
- [Hub: Exception Tracking FAQ](https://thehub.github.com/epd/engineering/dev-practicals/observability/exception-tracking/faq/) — rate limiting, failbotg delivery
- [Hub: Sentry Exceptions in Splunk](https://thehub.github.com/epd/engineering/dev-practicals/observability/sentry-exceptions-in-splunk/) — all exceptions go to Splunk's `prod-exceptions` index
- [Hub: Background Jobs Observability](https://thehub.github.com/epd/engineering/products-and-services/dotcom/background-jobs/observability/) — exception tracking for Resque jobs
- [Hub: GraphQL Debugging with Sentry](https://thehub.github.com/epd/engineering/products-and-services/public-apis/graphql/debugging/sentry-splunk/)

## GitHub's Sentry Organization

| Field | Value |
|---|---|
| Web URL | https://github.sentry.io |
| Region URL | https://us.sentry.io |
| Organization slug | `github` |

### Key Projects

| Project | ID | Purpose |
|---|---|---|
| heaven | 1884186 | Main Rails monolith (github/github) |

## Sentry Rate Limiting

Sentry has a per-project rate limit of **300 requests/second**. If you're missing exceptions:

1. **All exceptions go to Splunk** — failbotg delivers every exception to the `prod-exceptions` Splunk index, regardless of Sentry rate limits
2. The `failbotg.app.needles` Datadog metric is accurate even when Sentry rate-limits — use it for true exception volume
3. Query Splunk for the complete picture:
   ```spl
   index=prod-exceptions catalog_service="github/pull_requests"
   ```
4. Use Sentry for stack traces and grouping; use Splunk for volume analysis

> If your exceptions come from a large shared project (like `github` or `github-user`), consider routing them to a separate Sentry project by setting the `app` key in your failbot context.

## GitHub-Specific Sentry Search Patterns

### Scope by catalog service

```
is:unresolved catalog_service:github/code_scanning
```

### Scope by controller

```
is:unresolved controller:"IssuesController"
```

Or for API controllers:

```
is:unresolved controller:Api::Issues api_route:/repositories/:repository_id/issues http.method:POST
```

### Scope by job class (background jobs)

```
is:unresolved job:AddToSearchIndexJob
```

### Scope by queue

```
is:unresolved queue:index_high
```

### Scope by stack filename (find exceptions from a specific file)

```
stack.filename:app/jobs/repository_push_job.rb
```

### Scope by current deploy branch

```
current_ref:your-branch-name
```

### Correlating Sentry with Splunk via request ID

Grab a slow request ID from Splunk:
```spl
index=rails controller=IssuesController action=show elapsed>=8 | table request_id
```

Then search in Sentry:
```
request_id:"FA42:EA6B:A4E866:BEF346:602F81B9"
```

This gives you the exception stack trace alongside the performance data.

## Correlating Sentry with Other Tools

### Sentry → Splunk
Sentry exception types map directly to Splunk `exception_type` fields. Use Sentry for stack traces, Splunk for volume/frequency.

### Sentry → Datadog
Use the request trace ID (if available in Sentry breadcrumbs) to find the corresponding Datadog APM trace.

## Getting Help

- Slack: [#observability](https://github.slack.com/archives/C9H0UJC2W) for general observability questions
- Pager: `.pager trigger observability-experience-oncall` for urgent issues
