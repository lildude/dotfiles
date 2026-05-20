# Sentry Troubleshooting Skill

Investigate exceptions, error spikes, and release regressions in Sentry using the Sentry MCP server.

## What This Skill Does

This skill helps you:
- Triage error spikes — find top exceptions by volume and impact
- Investigate specific issues — get full stack traces, affected users, environments
- Detect release regressions — identify new errors introduced by recent deploys
- Correlate errors with performance — link Sentry exceptions to slow endpoints
- Use AI root cause analysis — leverage Sentry's Seer for code-level fix suggestions

## When to Use This Skill

Use this skill when you need to:
- "Find recent exceptions in my project"
- "What errors spiked after the last deploy?"
- "Get the stack trace for this Sentry issue"
- "Which releases introduced new errors?"
- "Analyze this error with AI root cause analysis"
- "How many errors are we seeing today?"
- "What are the top exceptions by volume?"

## Prerequisites

- Sentry MCP server configured (remote HTTP — no local install needed)
- Access to your Sentry organization

## Installation

```bash
# Personal skill
gh hubber-skills install sentry-troubleshooting-skill

# Or for a specific project
gh hubber-skills install sentry-troubleshooting-skill --project
```

Or manually:
```bash
ln -s "$(pwd)/sentry-troubleshooting-skill" ~/.copilot/skills/
```

## Usage

Trigger this skill by asking:
- "Debug the Sentry errors after our last release"
- "Find the top exceptions in project X"
- "Get the stack trace for Sentry issue PROJ-1234"
- "Are there new errors since yesterday's deploy?"
- "Analyze this Sentry issue with AI"

## Examples

This skill includes worked investigations under the `examples/` directory:

- `examples/post-deploy-error-spike.md` — Investigate a spike in errors after a deploy: find new issues, get stack traces, determine root cause.
- `examples/correlate-sentry-splunk.md` — Cross-reference a Sentry exception with Splunk logs to understand volume (accounting for Sentry rate limiting) and request context.

## References

- `references/sentry-search-syntax.md` — Sentry search queries for GitHub: scoping by service, controller, job, queue, deploy branch, and request ID. Includes key gotchas.

## Related Skills

- **datadog-troubleshooting-skill**: For debugging monitoring/alerting issues
- **splunk-log-analysis-skill**: For raw log queries and volume analysis
