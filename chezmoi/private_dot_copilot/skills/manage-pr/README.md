# Manage PR Skill

Drive a pull request from "review feedback received" to "ready to merge" through the address → reply → resolve → request-review → watch-CI loop.

## When to Use This Skill

- "Address all the open review comments on PR #X."
- "Re-request Copilot review on this PR."
- "Wait for CI to finish."
- "Loop on this PR until it's clean."
- "What's the state of PR #X?"

For raw CI watching only, prefer the `watch-ci` skill. For waiting on a single CCR pass, prefer `wait-for-copilot-code-review`. Use this skill when you want the full address-feedback + watch loop.

## Why This Skill Exists

Driving PRs through review iteration is full of small surprises:

- The login you'd guess (`Copilot`) only works the **first** time you request a Copilot review. Subsequent re-requests need `copilot-pull-request-reviewer[bot]`.
- A re-request POST returns 201 even when GitHub silently dedup's it; you have to verify.
- CCR is tied to specific commit SHAs and runs as the `Running Copilot Code Review` workflow.

This skill encodes those gotchas so you don't burn an hour on each one.

## Installation

```bash
gh hubber-skills install manage-pr-skill
```

## Usage

This skill activates when you ask Copilot to:

- "Address the PR feedback on github/agent-skills#289"
- "Re-request a Copilot review on this PR"
- "Wait for CI on PR #42 and tell me if anything fails"
- "Iterate on this PR until it's ready to merge"

The skill will:

1. Snapshot the PR (one GraphQL read: threads + CI + mergeability)
2. Apply fixes for unresolved threads
3. Push, then reply on and resolve each addressed thread
4. Request (or re-request) Copilot review
5. Watch CCR + CI to completion
6. Loop until clean

## Files

- `SKILL.md` — full skill instructions
- `references/copilot-code-review.md` — CCR re-request gotcha + workflow timing
- `references/bulk-resolve.md` — bash template for replying + resolving N threads
- `references/gh-pr-snippets.md` — copy-pasteable `gh api` commands
