# Example: Endpoint error breakdown

## Scenario

You want to understand the error profile of a specific endpoint — what status codes it's returning and what exceptions are being thrown.

## Prompt

```
Analyze errors for DiscussionsController#index — show me status code breakdown and exception types.
```

## SPL Generated

### Status code distribution

```spl
index=rails controller=DiscussionsController action=index earliest=-24h latest=now
| stats count by http.status_code
| sort -count
```

### Exception types for this endpoint

```spl
index=prod-exceptions rails.controller.name=DiscussionsController rails.controller.action=index earliest=-24h latest=now
| stats count by exception_type
| sort -count
```

> **Note**: The `prod-exceptions` index uses `rails.controller.name` not `controller`, and `rails.controller.action` not `action`.

## Expected Output

```markdown
## Log Analysis: DiscussionsController#index Error Breakdown (24h)

### Status Code Distribution
| Status Code | Count | % |
|---|---|---|
| 200 | 45,230 | 97.8% |
| 500 | 512 | 1.1% |
| 503 | 341 | 0.7% |
| 404 | 127 | 0.3% |
| 422 | 23 | <0.1% |

- [Status codes query](https://splunk.githubapp.com/en-US/app/search/search?q=search%20index%3Drails%20controller%3DDiscussionsController%20action%3Dindex%20%7C%20stats%20count%20by%20http.status_code%20%7C%20sort%20-count&earliest=-24h&latest=now)

### Exception Types (from prod-exceptions)
| Exception Type | Count |
|---|---|
| ActiveRecord::ConnectionTimeoutError | 312 |
| GitHub::RequestDurationManager::TimeBudgetIsOverError | 201 |
| Trilogy::TimeoutError | 89 |

- [Exception types query](https://splunk.githubapp.com/en-US/app/search/search?q=search%20index%3Dprod-exceptions%20rails.controller.name%3DDiscussionsController%20rails.controller.action%3Dindex%20%7C%20stats%20count%20by%20exception_type%20%7C%20sort%20-count&earliest=-24h&latest=now)

### Recommendations
- 503s (0.7%) are likely timeouts — correlate with the TimeBudgetIsOverError exceptions
- Connection timeouts suggest database pool saturation — check the issues-pull-requests MySQL cluster
- Generate a flamegraph for this endpoint to find the CPU bottleneck
```
