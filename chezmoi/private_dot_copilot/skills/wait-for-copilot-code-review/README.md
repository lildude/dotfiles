# Wait for Copilot Code Review

Background monitoring for Copilot code review completion on GitHub pull requests, using a zero-token shell polling approach.

## What It Does

Launches a lightweight shell script that polls for Copilot code review status on a PR. The agent sleeps (consuming no LLM tokens) while the script polls. When the review lands, the agent wakes up, reads the review comments, and asks what you'd like to do.

## Installation

### Personal skill (recommended)

```bash
# Symlink into your personal skills directory
ln -s /path/to/wait-for-copilot-code-review-skill ~/.copilot/skills/wait-for-copilot-code-review-skill
```

### Project skill

```bash
# Copy into your project
cp -r wait-for-copilot-code-review-skill .github/skills/wait-for-copilot-code-review-skill
```

## Usage

Just ask:

- "Watch for Copilot review on this PR"
- "Let me know when Copilot finishes reviewing"
- "Monitor Copilot review on PR #123"
- "Watch code review and tell me what to fix"

The agent will:

1. Launch a background shell script that polls `gh pr view` for Copilot's review
2. Sleep (zero tokens burned) while the script polls every 30 seconds
3. Wake up when the review is detected
4. Read the review comments and present them to you
5. Ask if you'd like help fixing any issues

## How It Works

The key insight is using `bash` with `mode="async"` to run a polling script, then `read_bash` with a delay to check back later — no LLM inference happens during the wait. The shell script does all the polling work.

```
┌─────────┐     ┌──────────────┐     ┌─────────┐
│  Agent   │────▶│ Shell Script │────▶│  Agent   │
│ (start)  │     │  (polling)   │     │ (resume) │
│ 1 turn   │     │  0 tokens    │     │ 1 turn   │
└─────────┘     └──────────────┘     └─────────┘
```

## Examples

See the [examples/](examples/) directory for detailed usage scenarios.
