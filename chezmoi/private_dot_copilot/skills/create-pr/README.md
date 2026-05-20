# create-pr

Skill for opening a high-quality pull request without forcing the user to clean up after you.

The two failure modes this skill exists to prevent:

1. **Colliding with the user's inflight branches** by creating a branch in their primary checkout. Always use a `git worktree` instead.
2. **Bouncing in review** because the PR body skipped the repo's PR template. Always read `.github/PULL_REQUEST_TEMPLATE*` and fill in every section that applies.

See `SKILL.md` for the full workflow and `references/template-formats.md` for field-by-field guidance on the github/github monolith template.
## Installation

```bash
gh hubber-skills install create-pr-skill
```
