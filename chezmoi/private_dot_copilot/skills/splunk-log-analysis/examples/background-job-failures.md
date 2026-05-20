# Example: Investigate background job failures

## Scenario

An alert fired for elevated background job failures. You need to identify which exception types are driving the failures, which jobs are affected, and generate a shareable Splunk link for the incident channel.

## Prompt

```
What background job failures are we seeing for the github/issues service? Group by error type.
```

## SPL Generated

```spl
index=prod-resque gh.catalog_service="github/issues" SeverityText="ERROR" earliest=-24h latest=now
| rex field=_raw "exception.type\":\"(?P<exception_type>[^\"]+)"
| stats count by exception_type
| sort -count
```

To also get the job class breakdown:

```spl
index=prod-resque gh.catalog_service="github/issues" SeverityText="ERROR" earliest=-24h latest=now
| rex field=_raw "exception.type\":\"(?P<exception_type>[^\"]+)"
| rex field=_raw "gh.job.name\":\"(?P<job_name>[^\"]+)"
| stats count by job_name, exception_type
| sort -count
```

## Expected Output

```markdown
## Log Analysis: Background Job Failures — github/issues (24h)

**Query**: `index=prod-resque gh.catalog_service="github/issues" SeverityText="ERROR"`
**Time range**: -24h to now
**Results**: 234 error events

### Breakdown by Exception Type
| Exception Type | Count | % |
|---|---|---|
| ActiveRecord::ConnectionTimeoutError | 142 | 60.7% |
| Trilogy::TimeoutError | 51 | 21.8% |
| ActiveRecord::RecordNotUnique | 28 | 12.0% |
| RuntimeError | 13 | 5.5% |

### Breakdown by Job + Exception
| Job | Exception | Count |
|---|---|---|
| UpdateIssueSearchIndexJob | ActiveRecord::ConnectionTimeoutError | 89 |
| NotifyIssueSubscribersJob | ActiveRecord::ConnectionTimeoutError | 53 |
| UpdateIssueSearchIndexJob | Trilogy::TimeoutError | 51 |

### Recommendations
- Connection timeouts dominate (82.5%) — check MySQL connection pool health
- UpdateIssueSearchIndexJob is the worst offender — check if search index backfill is running
- Query Splunk `prod-exceptions` for full stack traces: `index=prod-exceptions catalog_service="github/issues" exception_type="ActiveRecord::ConnectionTimeoutError"`
```

## Shareable Splunk URL

```bash
python3 splunk_url.py --name="Issues job failures (24h)" 'search index=prod-resque gh.catalog_service="github/issues" SeverityText="ERROR" | rex field=_raw "exception.type\":\"(?P<exception_type>[^\"]+)" | stats count by exception_type | sort -count'
```
