# Common SPL Patterns for GitHub

Quick-reference patterns used frequently when investigating dotcom issues. All patterns use GitHub-specific indexes and fields.

## Error Investigation

```spl
# Exception types for a service
index=prod-exceptions catalog_service="github/<service>"
| stats count by exception_type | sort -count

# Exceptions for a specific controller (note: different field names than rails index)
index=prod-exceptions rails.controller.name=<Controller> rails.controller.action=<action>
| stats count by exception_type | sort -count

# Timeout pages
index=rails timeout=true | stats count by controller, action | sort -count
```

## Performance

```spl
# Slow pages by URL
index=rails controller=<Controller> action=<action>
| stats avg(elapsed) as avg_s count by url | sort -avg_s

# GLB latency (load balancer level)
index=glb rails_controller="<controller>" rails_action="<action>" status="200"
| stats p50(ta) p99(ta) p50(rails_request_time) p99(rails_request_time)

# Perf summary by controller#action
index=rails deployment.environment=production catalog_service="github/<service>"
| eval controller_action = controller+"#"+action
| stats p50(elapsed), p99(elapsed), count, sum(elapsed) by controller_action
```

## Background Jobs

```spl
# Job failures by exception type
index=prod-resque gh.catalog_service="github/<service>" SeverityText="ERROR"
| rex field=_raw "exception.type\":\"(?P<exception_type>[^\"]+)"
| stats count by exception_type | sort -count

# Job logs by class name
index=prod-resque gh.job.name=<JobClassName>
```

## Cross-Index Correlation

```spl
# Full request context (run all three for the same request_id)
index=rails request_id="<REQUEST_ID>"
index=glb request_id="<REQUEST_ID>"
index=prod-exceptions gh.request_id="<REQUEST_ID>"
```

## Killed SQL

```spl
# Killed queries by pattern
index=prod-quoroner | regex query="._<controller>/<action>._"

# Killed queries by request ID
index=prod-quoroner | rex field=query "request_id:(?<request_id>.*?)[,|*]"
| search request_id=<REQUEST_ID>
```
