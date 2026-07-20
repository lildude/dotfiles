# Watch CI Skill

Automatically monitor CI/CD pipeline status and get notified when checks pass, fail, or require attention.

## When to Use This Skill

- Waiting for CI checks to complete on a pull request
- Monitoring build status while working on other tasks
- Getting alerts when tests fail or checks require action
- Background monitoring of required checks

## Installation

### Personal Skills
```bash
cp -r watch-ci-skill ~/.copilot/skills/
```

### Project Skills
```bash
cp -r watch-ci-skill /path/to/repo/.github/skills/
```

## Usage

This skill activates when you ask Copilot to:
- "Watch CI and let me know when it's green"
- "Monitor checks for PR #123"
- "Alert me when CI passes"
- "Keep an eye on the build status"
- "Watch for CI failures"

The skill will:
1. Identify the PR or commit to monitor
2. Check required status checks
3. Poll for updates
4. Notify you when status changes (green/red)
5. Optionally suggest next actions on failure

## Features

- **Background monitoring** - Runs as a background task so you can continue working
- **Smart notifications** - Only alerts on important status changes
- **Failure details** - Shows which checks failed and links to logs
- **Next actions** - Suggests what to do when checks fail

## Examples

### Basic PR monitoring
```bash
# User: "Watch CI on PR #456 and let me know when it's done"
# Agent: Monitoring PR #456. I'll notify you when all required checks complete.
```

### Current branch
```bash
# User: "Watch CI for my current branch"
# Agent: Watching checks for branch feature/new-api. I'll alert you when status changes.
```

### With auto-actions
```bash
# User: "Watch CI and auto-merge when green"
# Agent: Monitoring checks. Will auto-merge PR #789 when all required checks pass.
```

## Tips

- Works best when run as a background task
- Can monitor multiple PRs simultaneously
- Respects required check settings from branch protection rules
- Integrates with GitHub notifications

---

**Note:** This skill requires GitHub CLI (`gh`) to be installed and authenticated.
