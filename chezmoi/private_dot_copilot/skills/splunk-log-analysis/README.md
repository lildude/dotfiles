# Splunk Log Analysis Skill

Query and analyze production logs in Splunk using the Splunk MCP server and SPL (Search Processing Language).

## What This Skill Does

This skill helps you:
- Write SPL queries to search production logs
- Investigate timeouts, errors, and slow requests from raw log data
- Correlate log events across services and time windows
- Build aggregate reports — error breakdowns, job outcome distributions, top affected resources
- Generate clickable Splunk URLs for sharing queries in issues and documents

## When to Use This Skill

Use this skill when you need to:
- "Search Splunk logs for timeout errors"
- "Find slow requests in the last hour"
- "Query background job failures"
- "Get error breakdowns from production logs"
- "Build a Splunk query for killed SQL queries"
- "Analyze request logs for a specific endpoint"
- "Correlate exceptions across services in Splunk"

## Prerequisites

- Splunk MCP server configured (see SKILL.md for setup)
- Access to your Splunk instance with a valid auth token
- [uv](https://docs.astral.sh/uv/) package manager
- [splunk-mcp](https://github.com/livehybrid/splunk-mcp) cloned locally

> **Note**: Splunk setup is more involved than Sentry (which is a 3-line remote MCP config). You'll need to clone a repo, install Python deps, get an entitlement, and generate a token. Budget 15-20 minutes for first-time setup. See SKILL.md for the full walkthrough.

## Installation

```bash
# Personal skill (via gh-hubber-skills)
gh hubber-skills install splunk-log-analysis-skill

# Or for a specific project
gh hubber-skills install splunk-log-analysis-skill --project
```

Or manually:
```bash
ln -s "$(pwd)/splunk-log-analysis-skill" ~/.copilot/skills/
```

## Included Utilities

### `splunk_url.py`

A Python helper script that generates clickable Splunk search URLs from SPL queries:

```bash
# Plain URL
python3 splunk_url.py 'search index=rails controller=IssuesController | stats count'

# Markdown link
python3 splunk_url.py --name="Issue requests" 'search index=rails controller=IssuesController | stats count'

# Custom time range
python3 splunk_url.py --earliest=-1h --latest=now 'search index=rails elapsed>5'
```

## Usage

Trigger this skill by asking:
- "Search Splunk for errors in the last hour"
- "Write a Splunk query to find timeout exceptions"
- "Analyze background job failures in Splunk"
- "Find the slowest requests today"
- "Help me write an SPL query for..."

## Examples

This skill includes worked examples under the `examples/` directory:

- `examples/slow-requests-last-hour.md` — Build an SPL query to find the slowest requests in the last hour and sort by latency.
- `examples/background-job-failures.md` — Investigate background job failures, group by error type, and generate a Splunk URL you can share in an incident.
- `examples/endpoint-error-breakdown.md` — Analyze errors for a specific endpoint and produce an error-rate breakdown by status code.

Each example shows the prompt, the SPL generated, expected output, and a shareable Splunk URL.

## References

Additional reference material lives under the `references/` directory:

- `references/splunk-spl-cheatsheet.md` — Common SPL patterns for GitHub's dotcom indexes.
- `references/common-fields.md` — Field names for each index (`rails`, `prod-exceptions`, `glb`, `prod-resque`, `prod-quoroner`) and how they differ.
- `references/splunk-docs-links.md` — Curated links to official Splunk docs and GitHub TheHub pages.

## Related Skills

- **datadog-troubleshooting-skill**: For monitoring and alerting issues in Datadog
