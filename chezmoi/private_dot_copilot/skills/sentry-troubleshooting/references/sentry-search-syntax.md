# Sentry Search Syntax for GitHub

Quick reference for Sentry search queries used at GitHub.

## Scoping Queries

### By catalog service
```
is:unresolved catalog_service:github/code_scanning
```

### By controller (web)
```
is:unresolved controller:"IssuesController"
```

### By controller + route (API)
```
is:unresolved controller:Api::Issues api_route:/repositories/:repository_id/issues http.method:POST
```

### By job class (background jobs)
```
is:unresolved job:AddToSearchIndexJob
```

### By queue
```
is:unresolved queue:index_high
```

### By stack filename
```
stack.filename:app/jobs/repository_push_job.rb
```

### By deploy branch
```
current_ref:your-branch-name
```

### By request ID (correlating with Splunk)
```
request_id:"FA42:EA6B:A4E866:BEF346:602F81B9"
```

## Time and Status Filters

### Unresolved issues in the last 24 hours
```
is:unresolved firstSeen:-24h
```

### Issues first seen after a deploy
```
is:unresolved firstSeen:>2026-03-12T14:30:00
```

### High priority issues only
```
is:unresolved issue.priority:[high, medium]
```

## Performance-Related Sentry Projects

GitHub has several Sentry projects relevant to performance:

- `github-timeout` — Requests that timed out
- `github-killed-query` — SQL queries that were killed

Search these with `controller` filters to find timeouts for your endpoint.

## Monitoring Deploys in Sentry

From [Hub: Monitoring a dotcom deployment](https://thehub.github.com/epd/engineering/devops/deployment/monitoring-a-dotcom-deployment/):

- **Release page**: Hubot gives you a link when deploy starts. Fails to load for the first few minutes — refresh after ~2 min. Doesn't auto-refresh.
- **Firehose**: [sentry.io/github/github/](https://sentry.io/github/github/) — check if pre-existing errors became more frequent (watch the graphs). Click the play button for auto-reload.
- **Default time range is 14 days**: Misleading for rapid deploys. Change to "Last hour" or "Last 24 hours" in the top-right.
- **"New" issues aren't always new**: Sentry isn't perfect at distinguishing new vs existing. Something being new during your deploy doesn't mean you caused it.
- Filter by your branch during canary: `current_ref:your-branch-name`

## Additional Scoping Patterns

### By code namespace and function (e.g., feature flags)
```
is:unresolved issue.priority:[high, medium] code.namespace:Vexi::Client
code.function:is_enabled
```

### By Hydro consumer processor
```
processor:MyProcessorClassName
```

### How `catalog_service` gets tagged

Exceptions get `catalog_service` in Sentry via:
1. **Manually**: `Failbot.report(e, catalog_service: "my-service")`
2. **Automatically**: [ServiceMapping middleware](https://github.com/github/github/blob/master/lib/github/service_mapping.rb) adds it from the request context

If your exceptions are missing `catalog_service`, check that your controller's namespace is mapped in ServiceMapping.

## Key Gotchas

- **Rate limit**: 300 req/s per project. If missing exceptions, check Splunk `prod-exceptions` index.
- **`firstSeen` vs `lastSeen`**: `firstSeen` = when Sentry first recorded the issue. `lastSeen` = most recent occurrence. For regression hunting, filter on `firstSeen`.
- **Sentry groups by stack trace**: A single root cause can appear as multiple issues if the call path varies.
- **Stacktrace truncation**: Sentry truncates at 250 frames. For full traces, check Splunk `prod-exceptions`.

## Sources

- [Hub: Exception Tracking FAQ](https://thehub.github.com/epd/engineering/dev-practicals/observability/exception-tracking/faq/)
- [Hub: Sentry Exceptions in Splunk](https://thehub.github.com/epd/engineering/dev-practicals/observability/sentry-exceptions-in-splunk/)
- [Hub: Monitoring a dotcom deployment](https://thehub.github.com/epd/engineering/devops/deployment/monitoring-a-dotcom-deployment/)
- [Hub: Dotcom deployment confidence](https://thehub.github.com/epd/engineering/devops/deployment/dotcom-deployment-confidence/) — Sentry tips for deploys
- [Hub: How to Fast — Sentry section](https://thehub.github.com/epd/engineering/dev-practicals/performance/techniques/how-to-fast-understanding-what-is-slow/#sentry)
- [Hub: Exception Reporting in the monolith](https://thehub.github.com/epd/engineering/products-and-services/dotcom/monolith-observability/exception-reporting/) — how `catalog_service` tagging works
- [Hub: Background Jobs Observability](https://thehub.github.com/epd/engineering/products-and-services/dotcom/background-jobs/observability/) — scoping by job, queue, filename
- [Hub: Feature Flags Monitoring](https://thehub.github.com/epd/engineering/products-and-services/dotcom/features/feature-flags/monitoring/) — Vexi error tracking
- [Sentry search syntax docs](https://docs.sentry.io/product/sentry-basics/search/)
