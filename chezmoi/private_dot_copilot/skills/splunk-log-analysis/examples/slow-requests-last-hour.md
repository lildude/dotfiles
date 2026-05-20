# Example: Find slow requests in the last hour

## Scenario

You're investigating reports of slow page loads. You want to find the slowest requests in the last hour and understand which controllers are affected.

## Prompt

```
Find the slowest requests in the last hour, sorted by latency.
```

## SPL Generated

```spl
index=rails elapsed>5 stamp=dotcom earliest=-1h latest=now
| stats count by controller, action
| sort -count
| head 20
```

For a specific controller:

```spl
index=rails controller=IssuesController action=show deployment.environment=production earliest=-1h latest=now
| stats avg(elapsed) as average_elapsed count by url
| sort -average_elapsed
```

## Expected Output

```markdown
## Log Analysis: Slow Requests (last hour)

**Query**: `index=rails elapsed>5 stamp=dotcom`
**Time range**: -1h to now
**Results**: 47 events

### Breakdown
| Controller | Action | Count |
|---|---|---|
| IssuesController | show | 18 |
| PullRequestsController | show | 12 |
| FilesController | disambiguate | 9 |
| DiscussionsController | index | 8 |

### Recommendations
- IssuesController#show has the most slow requests — capture a flamegraph to identify the bottleneck
- Check GLB latency alongside Rails elapsed time to see if queuing is a factor
```

## Shareable Splunk URL

```bash
python3 splunk_url.py --name="Slow requests (1h)" --earliest=-1h 'search index=rails elapsed>5 stamp=dotcom | stats count by controller, action | sort -count | head 20'
```
