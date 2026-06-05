---
name: splunk-log-analysis
description: This skill should be used when the user asks to "search Splunk logs", "write SPL query", "find errors in Splunk", "analyze production logs", "query Splunk for timeouts", "investigate log patterns", or needs to search and analyze structured logs in Splunk
version: 1.0.0
---

# Splunk Log Analysis

You are an expert at querying and analyzing production logs in Splunk using SPL (Search Processing Language). You use the Splunk MCP server to run queries, discover indexes, and analyze results.

## When to Use This Skill

- Investigating timeout errors or slow requests in production logs
- Building SPL queries to analyze error breakdowns by type, controller, or service
- Finding killed SQL queries or request-level exceptions
- Correlating log events across indexes by request ID or trace ID
- Analyzing background job failures and outcome distributions
- Generating shareable Splunk URLs for issues, PRs, or reports

## Boundaries

**Will:**
- Build and execute SPL queries against Splunk indexes
- Discover available indexes and data sources
- Extract and aggregate fields from log data
- Generate shareable Splunk URLs
- Produce structured analysis reports with query links

**Will not:**
- Create or delete Splunk indexes
- Modify Splunk configuration or saved searches
- Write data to Splunk
- Access indexes you don't have entitlements for

## Prerequisites

Splunk doesn't have a remote MCP endpoint yet. Instead, you clone [splunk-mcp](https://github.com/livehybrid/splunk-mcp) locally — it's a Python MCP server that acts as a bridge between VS Code's MCP protocol and Splunk's REST API. You configure it in `.vscode/mcp.json` with your Splunk host and token, and VS Code launches it automatically whenever Copilot needs to talk to Splunk. Without it, Copilot wouldn't know how to query Splunk. Set up:

1. Install [uv](https://docs.astral.sh/uv/): `brew install uv`
2. Clone the wrapper: `git clone https://github.com/livehybrid/splunk-mcp ~/projects/splunk-mcp`
3. Install dependencies: `cd ~/projects/splunk-mcp && uv sync`
4. Ensure you can generate Splunk tokens — add yourself to the appropriate [entitlement](https://github.com/github/entitlements/blob/05032509ab95ab65cc1dc56d52536c82581a9629/ldap/apps/splunk/splunk-capability-generate-tokens.txt)
5. Generate a Splunk auth token via [the token page](https://splunk.githubapp.com/en-GB/manager/gh_reference_app/authorization/tokens) for the MCP Server app
6. Add to `.vscode/mcp.json`:

```json
{
  "servers": {
    "splunk": {
      "type": "stdio",
      "command": "/path/to/uv",
      "args": [
        "--directory", "/path/to/splunk-mcp",
        "run", "python", "splunk_mcp.py", "stdio"
      ],
      "env": {
        "SPLUNK_HOST": "splunkazure-api-azure-eastus.octoca.ts.net",
        "SPLUNK_PORT": "443",
        "SPLUNK_TOKEN": "<your-splunk-mcp-token>",
        "SPLUNK_SCHEME": "https",
        "VERIFY_SSL": "true",
        "FASTMCP_LOG_LEVEL": "DEBUG"
      }
    }
  }
}
```

Replace paths with your actual `which uv` output and clone location.

> Add `.vscode/` to `.gitignore` — the config contains your Splunk token.

## Investigation Methodology

### Step 1: Understand the Question

Determine what you're looking for:

1. **Error investigation** → Search for exception types, error severity
2. **Timeout analysis** → Search for timeout markers, slow request durations
3. **Volume analysis** → Aggregate counts over time
4. **Correlation** → Link events across indexes by request ID, trace ID, or timestamp

Ask the user for:
- **Index** to search (or use `splunk-list_indexes` / `splunk-get_indexes_and_sourcetypes`; `list_indexes` / `get_indexes_and_sourcetypes` in some clients)
- **Time window** (last hour, last 24h, specific range)
- **Search terms** — error messages, job names, endpoint paths, user IDs
- **What they want to know** — counts, individual events, trends, breakdowns

### Step 2: Build the SPL Query

For MCP execution, pass the query body without a leading `search` command. Splunk MCP tools are usually shown with a `splunk-` server prefix in Copilot CLI (`splunk-search_splunk`, `splunk-list_indexes`, `splunk-get_indexes_and_sourcetypes`) and without that prefix in some other clients (`search_splunk`, `list_indexes`, `get_indexes_and_sourcetypes`). The search tool prepends `search` plus a space before sending the SPL to Splunk:

```spl
index=<index> <search terms> earliest=-<time> latest=now
| <transformations>
| <output>
```

For Splunk Web UI searches and shareable URLs, include the explicit `search` command:

```spl
search index=<index> <search terms> earliest=-<time> latest=now
| <transformations>
| <output>
```

See the GitHub-Specific SPL Patterns section below for real query examples using dotcom indexes and fields.

### Step 3: Execute and Analyze

Run the query via `splunk-search_splunk` (`search_splunk` in some clients) and interpret results:

1. **Check result count** — empty results may mean wrong index, time range, or search terms
2. **Look for patterns** — cluster errors by type, time, or source
3. **Refine the query** — narrow with additional filters or broaden the time window
4. **Extract fields** — use `rex` to pull structured data from raw log lines

### Step 4: Report Findings

Present results in this format:

```markdown
## Log Analysis: <Title>

**Query**: `<SPL query used>`
**Time range**: <earliest> to <latest>
**Results**: <count> events

### Findings
<key observations from the data>

### Breakdown
| Category | Count | % |
|---|---|---|
| ... | ... | ... |

### Recommendations
<what to investigate next or actions to take>
```

## Generating Shareable Splunk URLs

When documenting queries in issues, PRs, or reports, provide clickable links instead of raw SPL blocks. Use the included `splunk_url.py` helper:

```bash
# Generate a plain URL
python3 splunk_url.py 'search index=prod-resque "CreateMergeCommitsJob" | stats count'

# Generate a markdown link with a name
python3 splunk_url.py --name="Job count" 'search index=prod-resque "CreateMergeCommitsJob" | stats count'

# Custom time range
python3 splunk_url.py --earliest=-1h --latest=now 'search index=rails controller=PullRequestsController'
```

### Presentation

Always present Splunk queries as clickable markdown links:

```markdown
### Splunk Queries
- [Error breakdown](https://splunk.githubapp.com/en-US/app/search/search?q=search%20index%3D...)
- [Timeout analysis](https://splunk.githubapp.com/en-US/app/search/search?q=search%20index%3D...)
```

This ensures queries are reproducible with one click and avoids copy-paste errors.

> **MCP vs Web UI reminder:** the examples in this section intentionally include `search` because they are for Splunk Web UI URLs. When executing the same query through `splunk-search_splunk`, drop the leading `search` and pass `index=... | ...`.

## Common Pitfalls

- **Wrong index**: Use `splunk-list_indexes` / `splunk-get_indexes_and_sourcetypes` (`list_indexes` / `get_indexes_and_sourcetypes` in some clients) to discover available indexes before querying. An empty result often means wrong index, not "no data."
- **Time range too narrow**: Start with `-24h` and narrow down. Very recent events may not be indexed yet.
- **Unstructured logs**: Many logs are unstructured text. Use `rex` to extract fields from `_raw` rather than assuming field names exist.
- **Large result sets**: Splunk defaults to returning 100 results. Use `| head N` to limit if you need fewer, or add `| stats` to aggregate instead of returning raw events.
- **Search head timeout**: Complex queries over large time ranges can timeout. Add more specific filters, reduce the time window, or use `| stats` early to reduce data.
- **Field name variations**: Different log sources encode fields differently. Check raw events first (`| head 5`) to understand the log format before writing extraction patterns.
- **Generating commands can't lead the query**: The `splunk-search_splunk` MCP tool (`search_splunk` in some clients) auto-prepends `search` plus a space to every query, so leading with a generating command like `| makeresults`, `| tstats`, or `| inputlookup` returns `HTTP 400 -- "This command must be the first command of a search."` Stick to the `index=<index> ... | <transformations>` form via the MCP. If you genuinely need `tstats` or `makeresults` as the first command (e.g. for performance), run it from the Splunk Web UI instead.
- **DNS failures usually mean Tailscale is disconnected**: The MCP container connects to `splunkazure-api-azure-eastus.octoca.ts.net`, a tailnet hostname routed through Tailscale's DNS (`100.100.100.100`). If you see `[Errno -3] Temporary failure in name resolution` from `splunk-health_check`/`health_check` or `splunk-search_splunk`/`search_splunk`, confirm Tailscale is connected (menu-bar icon on macOS, or `tailscale status`). The MCP server's own `splunk-ping`/`ping` still works because it's local — only Splunk calls fail.

## Validation Checklist

Before reporting findings:

- [ ] Confirmed the correct index and time range
- [ ] Verified results are from the expected environment (prod, not staging)
- [ ] Checked raw events (`| head 5`) to validate field extractions
- [ ] Included counts and percentages, not just examples
- [ ] Provided shareable Splunk URLs for all queries
- [ ] Cross-referenced with other data sources if making causal claims

## GitHub Splunk Instance

GitHub runs Splunk across multiple regional instances. The MCP server connects to the REST API endpoint; clickable links for humans use the web UI.

| Endpoint | Purpose |
|---|---|
| `splunk.githubapp.com` | **Web UI** — for dotcom and Proxima US stamps |
| `splunk-eu.githubapp.com` | **Web UI** — for Proxima EU stamps |
| `splunkazure-api-azure-eastus.octoca.ts.net` | **REST API** — used by the MCP server (set as `SPLUNK_HOST`) |

> The REST API host above is for the primary US instance. If you work with EU stamps, check the [Splunk repo](https://github.com/github/splunk#frequently-used-dns-entries) for regional API endpoints or ask in [#splunk](https://github.slack.com/archives/CCYGBERC4).

### Key Indexes

| Index | Contents |
|---|---|
| `rails` | Dotcom web request logs |
| `glb` | GLB/HAProxy request logs — has `ta` (total latency) and `rails_request_time` |
| `prod-resque` | Background job logs (Resque workers) |
| `prod-exceptions` | All exceptions (delivered by failbotg — includes exceptions rate-limited by Sentry) |
| `prod-quoroner` | Killed SQL queries |
| `prod-varnish` | Varnish validation logs |
| `catchall` | Container logs from kube workers — scope with `kube_namespace=github-production`. **Being sunset** — teams should migrate to dedicated indexes. |

### Key Fields (dotcom `rails` index)

From the [Hub field reference](https://thehub.github.com/epd/engineering/incident-response/being-on-call/splunk/#field-reference):

| Field | Description | Example |
|---|---|---|
| `controller` | Rails controller | `PullRequestsController` |
| `action` | Rails action | `show` |
| `elapsed` | Request duration (seconds) | `0.453` |
| `status` / `http.status_code` | HTTP status code (both field names are valid) | `200` |
| `route` | Rails route pattern | `/repositories/:repository_id/issues/:id` |
| `user` | Authenticated username (web) | `monalisa` |
| `current_user` | Authenticated username (API) | `monalisa` |
| `repo` | Repository nwo | `github/github` |
| `repo_visibility` | Repository visibility | `private` |
| `request_id` | Unique request identifier | `A1C0:764A:82C13F:878361:62F2C36F` |
| `request_category` | Request type | `api`, `browser` |
| `request_method` | HTTP method | `GET`, `POST` |
| `request_host` | Request hostname | `github.com` |
| `code.namespace` | Ruby class/namespace | `Search::Queries::IssueQuery` |
| `catalog_service` | Service catalog name | `github/issues` |
| `stamp` | Deployment stamp | `dotcom` |
| `app` | Application name | `github`, `hookshot`, `heaven` |
| `version` | API version (API requests) | `v3` |
| `timeout` | Whether request timed out | `true` |
| `path_info` | Request path | `/github/github/issues/123` |

> **Note**: The `prod-exceptions` index uses `rails.controller.name` instead of `controller`, and `rails.controller.action` instead of `action`.

## GitHub-Specific SPL Patterns

### Request performance by controller

```spl
index=rails controller=PullRequestsController
| stats avg(elapsed) as avg_s, p95(elapsed) as p95_s, count by action
| sort -count
```

### Top slow pages (>5s)

```spl
index=rails elapsed>5 stamp=dotcom
| stats count by controller, action
| sort -count
| head 20
```

### GLB latency for an endpoint

```spl
index=glb backend=kubernetes_web_unicorn_clusters rails_controller="issues" rails_action="show" rails_request_category="browser" status="200"
| stats p50(ta) p50(rails_request_time) p99(ta) p99(rails_request_time)
```

### Timeouts by controller

```spl
index=rails timeout=true
| stats count by controller, action
| sort -count
```

### Exception breakdown for a service

```spl
index=prod-exceptions catalog_service="github/pull_requests"
| stats count by exception_type
| sort -count
```

### Exceptions for a specific controller

```spl
index=prod-exceptions rails.controller.name=PullRequestsController rails.controller.action=show
| stats count by exception_type
| sort -count
```

### Killed SQL queries

```spl
index=prod-quoroner | regex query="._profiles/stars#index._"
```

### Killed SQL queries by request ID

```spl
index=prod-quoroner | rex field=query "request_id:(?<request_id>.*?)[,|*]" | search request_id=A6B0:740E:CEB56A:E632DD:62AC89A9
```

### Background job failures

```spl
index=prod-resque gh.catalog_service="github/issues" SeverityText="ERROR"
| rex field=_raw "exception.type\":\"(?P<exception_type>[^\"]+)"
| stats count by exception_type
| sort -count
```

### Background job logs by class

```spl
index=prod-resque gh.job.name=ConvertTeamDiscussionsToDiscussionsJob
```

### Load analysis by route (API)

```spl
index=rails stamp=dotcom catalog_service=github/issues request_category=api
| stats count by gh.request.api.route, code.namespace
| sort -count
| head 100
```

### Finding logs for a specific request

```spl
index=rails request_id="A1C0:764A:82C13F:878361:62F2C36F"
```

### Correlating exceptions with request logs

```spl
# Find the exception
index=prod-exceptions gh.request_id=REQUEST_ID

# Then cross-reference with rails logs
index=rails request_id=REQUEST_ID
```

### Correlating GLB and Rails logs

```spl
index=glb request_id=REQUEST_ID
```

### Finding slow pages

```spl
index=rails controller=DiscussionsController action=index
| stats avg(elapsed) as average_elapsed count by url
| sort -average_elapsed
```

### Status code distribution for an endpoint

```spl
index=rails controller=DiscussionsController action=index
| stats count by http.status_code
| sort -count
```

### Timeout pages (requests near or at the 10s limit)

```spl
index=rails controller=IssuesController action=show deployment.environment=production elapsed>=9.9
| where isnull(gh.actor.id)
| stats count by path_info
| sort count desc
```

### Tabular perf data by catalog service

```spl
index=rails deployment.environment=production catalog_service="github/github_sponsors"
| eval controller_action = controller+"#"+action
| stats p50(elapsed), p99(elapsed), count, sum(elapsed) by controller_action
```

### Varnish correlation via subsearch

Find GLB logs for requests where Varnish failed validation:

```spl
index=glb [search index=prod-varnish msg="failed to validate request" | table request_id] | stats count by status
```

### Correlating Splunk request IDs to Sentry

Grab slow request IDs from Splunk, then search them in Sentry for stack traces:

```spl
# 1. Find slow request IDs in Splunk
index=rails controller=IssuesController action=show elapsed>=8
| table request_id
```

Then search Sentry with: `request_id:"<ID_FROM_ABOVE>"`

### Circuit breaker Trilogy errors

```spl
index=rails Body="encountered a trilogy error" "gh.trilogy.circuit_breaker.result"="failure"
```

## Getting Help

- Slack: [#splunk](https://github.slack.com/archives/CCYGBERC4) for Splunk-specific questions
- Slack: [#observability](https://github.slack.com/archives/C9H0UJC2W) for general observability
- Team: `@github/security-telemetry` owns the Splunk infrastructure

## References

- [Splunk MCP wrapper](https://github.com/livehybrid/splunk-mcp)
- [SPL2 Search Reference](https://docs.splunk.com/Documentation/SplunkCloud/latest/SearchReference/WhatsInThisManual)
- [Splunk Search Tutorial](https://docs.splunk.com/Documentation/Splunk/latest/SearchTutorial/WelcometotheSearchTutorial)
- [Hub: Splunk Cookbook](https://thehub.github.com/epd/engineering/dev-practicals/performance/tools/splunk/) — performance queries: slow pages, timeouts, exceptions, background jobs
- [Hub: A Splunk guide for dotcom](https://thehub.github.com/epd/engineering/incident-response/being-on-call/splunk/) — field reference, commands, advanced usage
- [Hub: Sentry Exceptions in Splunk](https://thehub.github.com/epd/engineering/dev-practicals/observability/sentry-exceptions-in-splunk/) — querying `prod-exceptions`
- [Hub: Splunk Recipes](https://thehub.github.com/epd/engineering/dev-practicals/observability/logging/splunk-recipes/) — OTel-based service log queries
- [Hub: Splunk-to-Kusto Guide](https://thehub.github.com/epd/engineering/dev-practicals/observability/logging/dotcom-kusto/splunk-to-kusto-guide/) — translating SPL to KQL
- [Hub: Background Jobs Observability](https://thehub.github.com/epd/engineering/products-and-services/dotcom/background-jobs/observability/) — `catchall` index for kube workers
- [Hub: GraphQL Debugging with Splunk](https://thehub.github.com/epd/engineering/products-and-services/public-apis/graphql/debugging/sentry-splunk/) — `gh.graphql.*` fields
