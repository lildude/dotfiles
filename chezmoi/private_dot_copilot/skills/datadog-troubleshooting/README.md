# Datadog Troubleshooting Skill

Systematically debug common Datadog monitor and SLO deployment issues with proven solutions.

## What This Skill Does

This skill helps you troubleshoot Datadog monitor issues by:
- Identifying error patterns from deployment failures
- Providing step-by-step recovery procedures
- Explaining root causes and prevention strategies
- Linking to relevant documentation and tools

## When to Use This Skill

Use this skill when you encounter:
- Monitor deployment errors in `github/datadog-monitoring`
- Missing auto-generated PRs for monitor changes
- Invalid payload errors
- Query validation failures
- Monitor or dashboard deletion issues
- Threshold mismatch errors

## Installation

Install with the [`gh skill`](https://cli.github.com/manual/gh_skill) command (built into recent versions of the [GitHub CLI](https://cli.github.com/)):

```bash
# Personal (available across all your projects)
gh skill install github/agent-config datadog-troubleshooting --scope user

# Project (checked into the current repository)
gh skill install github/agent-config datadog-troubleshooting --scope project
```

## Usage

Trigger this skill by asking:
- "Debug my Datadog monitor deployment error"
- "Why is my monitor failing to deploy?"
- "Fix Datadog invalid payload error"
- "My monitor PR wasn't created, help!"
- "Troubleshoot Datadog monitor issues"

## Examples

See the [examples directory](./examples/) for real error messages and their solutions.

## Related Skills

- **datadog-monitor-setup**: Guide for creating monitors correctly from the start
