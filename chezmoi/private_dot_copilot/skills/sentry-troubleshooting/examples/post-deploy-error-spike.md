# Example: Post-deploy error spike investigation

## Scenario

A deploy just went out and the error rate spiked. You need to find what new exceptions appeared, get stack traces, and determine if the deploy caused them.

## Prompt

```
We just deployed and errors are spiking. Can you check Sentry for new issues in the heaven project?
```

## Investigation Flow

### 1. Find recent releases

Ask the Sentry MCP to find releases:

```
Find the last 3 releases for the heaven project in the github org
```

This returns release versions and timestamps, letting you identify which deploy just went out.

### 2. Search for new issues since the deploy

```
Search for issues in heaven first seen in the last 2 hours
```

### 3. Get details on the worst offender

```
Get the full details for Sentry issue HEAVEN-12345
```

## Expected Output

````markdown
## Error Investigation: Post-Deploy Spike (2026-03-12 14:30 UTC)

**Release**: `v20260312.1430` deployed at 14:30 UTC

### New Issues Since Deploy

| Issue | Type | Events | Users |
|---|---|---|---|
| HEAVEN-12345 | ActiveRecord::ConnectionTimeoutError | 342 | 89 |
| HEAVEN-12346 | Trilogy::TimeoutError | 156 | 45 |
| HEAVEN-12347 | RuntimeError | 23 | 12 |

### Stack Trace (HEAVEN-12345)

Key frames (application code only):
```
app/models/repository.rb:234 in `find_with_cache`
app/controllers/repositories_controller.rb:56 in `show`
```

### Root Cause

Connection pool exhaustion on the issues-pull-requests MySQL cluster.
The deploy included a change that adds an extra query per request to
`RepositoriesController#show`, pushing the connection pool over capacity
during peak traffic.

### Impact
- Environments: production (dotcom stamp)
- Affected endpoint: `RepositoriesController#show` (browser + API)
- 342 errors in 2 hours, 89 unique users affected

### Recommended Fix
- Immediate: revert the deploy or increase connection pool size
- Long-term: cache the new query or batch it with existing queries

### Cross-tool verification
- Splunk volume check: `index=prod-exceptions catalog_service="github/repositories" exception_type="ActiveRecord::ConnectionTimeoutError"`
- Datadog metric: check `failbotg.app.needles` for true exception volume (Sentry may be rate-limiting)
````
