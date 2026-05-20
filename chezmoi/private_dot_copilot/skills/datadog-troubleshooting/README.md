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

Copy or symlink the skill to your Copilot CLI skills directory:

```bash
# Using symlink (recommended for development)
ln -s "$(pwd)/datadog-troubleshooting-skill" ~/.copilot-cli/skills/

# Or copy the directory
cp -r datadog-troubleshooting-skill ~/.copilot-cli/skills/
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

- **datadog-monitor-setup-skill**: Guide for creating monitors correctly from the start
