# create-pr

Skill for opening a high-quality pull request without forcing the user to clean up after you.

The two failure modes this skill exists to prevent:

1. **Colliding with the user's inflight branches** by creating a branch in their primary checkout. Always use a `git worktree` instead.
2. **Bouncing in review** because the PR body skipped the repo's PR template. Always read `.github/PULL_REQUEST_TEMPLATE*` and fill in every section that applies.

See `SKILL.md` for the full workflow and `references/template-formats.md` for how to read and fill any repo's PR template — and how its label markers work — without hardcoding a specific template.
## Installation

```bash
gh skill install github/agent-config create-pr --scope user
```
