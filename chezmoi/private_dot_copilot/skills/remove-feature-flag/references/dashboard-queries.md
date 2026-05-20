# Dashboard queries for verifying FF rollout

The standard "Feature Flag Results" dashboard at `https://app.datadoghq.com/dashboard/rc6-kc7-y2u` accepts a `tpl_var_feature_flag` template variable in the URL and exposes separate Monolith and Go Services sections. The metrics differ by tier — use the right one.

## Go Services (Vexi Go client)

```
count:vexi.is_enabled.duration{feature_flag.key:<flag-key>,gh.vexi.is_enabled.result:true}.as_count()
count:vexi.is_enabled.duration{feature_flag.key:<flag-key>,gh.vexi.is_enabled.result:false}.as_count()
```

Percentage formula: `true / (true + false) * 100`

## Monolith (Ruby / Vexi Ruby client)

The monolith records to three sub-metrics depending on call path:

```
count:gh.vexi.is_enabled.duration.cached{feature_flag.key:<flag-key>,result:true}.as_count()
count:gh.vexi.is_enabled.duration.cached{feature_flag.key:<flag-key>,result:false}.as_count()
count:gh.vexi.is_enabled.duration.memoized{feature_flag.key:<flag-key>,result:true}.as_count()
count:gh.vexi.is_enabled.duration.memoized{feature_flag.key:<flag-key>,result:false}.as_count()
count:gh.vexi.is_enabled.duration.adapter_called{feature_flag.key:<flag-key>,result:true}.as_count()
count:gh.vexi.is_enabled.duration.adapter_called{feature_flag.key:<flag-key>,result:false}.as_count()
```

Percentage formula (matches the dashboard widget):
`(t_cached + t_memoized*100 + t_adapter) / (t_cached + t_memoized*100 + t_adapter + f_cached + f_memoized*100 + f_adapter) * 100`

Memoized counts dominate because most checks are cheap memo hits, hence the *100 weighting in the formula.

## Sanity rules

- **Window: 7 days minimum.** A flag can sit at 100% for an hour because traffic is low; 7d is what the dashboard defaults to and what's safe.
- **Both sides must be present.** If `false` is `null` *and* `true` is also `null`, the flag may not even exist or be checked anywhere — investigate before declaring it safe to remove.
- **Tier match.** A Go-service flag won't appear in monolith metrics and vice versa. Verify the tier before assuming "no data" means "fully rolled out."
- **`name_filter` first.** Use `search_datadog_metrics` (Datadog MCP) with `name_filter:vexi.is_enabled` once at the start of a session to confirm the metric is actively reporting in the org.

## Datadog MCP scalar query template

```jsonc
{
  "from": "now-7d",
  "to": "now",
  "response_format": "scalar",
  "queries": [
    {
      "name": "true_count",
      "aggregator": "sum",
      "query": "count:vexi.is_enabled.duration{feature_flag.key:<flag-key>,gh.vexi.is_enabled.result:true}.as_count()"
    },
    {
      "name": "false_count",
      "aggregator": "sum",
      "query": "count:vexi.is_enabled.duration{feature_flag.key:<flag-key>,gh.vexi.is_enabled.result:false}.as_count()"
    }
  ]
}
```

Run several flag candidates in **parallel** (multiple `get_datadog_metric` calls in one response) when sweeping a repo for "any flag at 100%". Don't loop one-at-a-time.

## Linking the dashboard from the PR body

The dashboard URL pre-loads with the flag if you set the template var:

```
https://app.datadoghq.com/dashboard/rc6-kc7-y2u?tpl_var_feature_flag=<flag-key>
```

Reviewers click that and see the rollout chart immediately — much friendlier than asking them to type the flag name into the dashboard themselves.
