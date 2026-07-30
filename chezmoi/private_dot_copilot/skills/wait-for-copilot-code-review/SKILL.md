---
description: Use when the user wants to be notified when Copilot finishes reviewing a PR — phrases like "watch for Copilot review", "wait for code review", "let me know when Copilot finishes reviewing", "monitor Copilot review", "watch code review", "alert when review is done".
metadata:
    github-path: skills/wait-for-copilot-code-review
    github-ref: refs/heads/main
    github-repo: https://github.com/github/agent-config
    github-tree-sha: 0af0c8f0a45d319e259456a1d0e96cca04e568ad
name: wait-for-copilot-code-review
---
# Watch Code Review - Zero-Token Background Polling

Monitors a pull request for Copilot code review completion using a background shell script. The agent consumes **zero LLM tokens** while the script polls, resuming only when the review lands.

## When to Use This Skill

- User just pushed a PR to a `github` org repo and wants to address Copilot review comments
- User wants to be notified when Copilot finishes reviewing their PR
- User says "watch for Copilot review", "let me know when the review is done", etc.
- After creating a PR, proactively offer to watch for Copilot review if the repo is in the `github` org

## Core Mechanism

The key technique: launch a shell script via `bash` in `async` mode, then use `read_bash` with a long delay to check back. The LLM is **not invoked** during the delay — only the shell script runs.

```
Agent turn 1:  bash(mode="async") → launches polling script → returns shellId
Agent turn 2:  read_bash(shellId, delay=120) → script still running → empty output
Agent turn 3:  read_bash(shellId, delay=120) → "REVIEW_COMPLETE" → agent resumes
```

## Implementation

### Step 1: Identify the PR

Determine which PR to watch:

```bash
# Current branch's PR
PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null)

# Or explicit PR number from user
PR_NUMBER=123
```

### Step 2: Launch the Polling Script

Run the bundled watcher with `bash` in `mode="async"` and keep the `shellId`:

```bash
# Resolve the installed skill dir, then call the script via "$SKILL_DIR/scripts/...".
SKILL_DIR=""  # start empty so the ${SKILL_DIR:?...} guard can't reuse a leaked value
for d in .github/skills/wait-for-copilot-code-review "$HOME/.copilot/skills/wait-for-copilot-code-review"; do
  [ -d "$d" ] && { SKILL_DIR="$d"; break; }
done
: "${SKILL_DIR:?wait-for-copilot-code-review skill dir not found in .github/skills or ~/.copilot/skills}"

# Watch the current branch's PR (defaults: interval 30s, timeout 3600s):
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
PR_NUMBER=$(gh pr view --json number --jq .number)
bash "$SKILL_DIR/scripts/watch-code-review.sh" "$REPO" "$PR_NUMBER"
# Alternative (run INSTEAD of the line above): pass an explicit PR URL, optionally with interval/timeout seconds:
# bash "$SKILL_DIR/scripts/watch-code-review.sh" https://github.com/github/github/pull/12345 30 3600
```

It fast-fails if you are not authenticated or the PR does not exist, stays silent
on stdout while polling (so the wait costs zero agent tokens), and prints only when
the review lands (`REVIEW_COMPLETE` plus the state, summary body, and inline
comments) or the timeout expires (`TIMEOUT`). Defaults: interval 30s, timeout 3600s.

**Critical implementation details:**

1. Use `bash` with `mode="async"` to launch the script — this gives you a `shellId`
2. The script produces NO output while polling (output would appear in `read_bash`)
3. Only when the review is found (or timeout) does it print, which `read_bash` will pick up

### Step 3: Wait with read_bash

After launching the script, use `read_bash` with a long delay. This is where the zero-token magic happens — the LLM is not invoked during the delay.

```
read_bash(shellId=<id>, delay=120)
```

**Choosing the delay:**
- Start with `delay=120` (2 minutes) — Copilot reviews typically take 1–5 minutes
- If no output, call `read_bash` again with `delay=120`
- The script handles its own polling interval (30s default); the `read_bash` delay is how often the agent checks if the script has output

### Step 4: Process the Result

When `read_bash` returns output containing `REVIEW_COMPLETE`:

1. Parse the review state and comments from the script output
2. Fetch the detailed review threads:
   ```bash
   gh pr view PR_NUMBER --repo OWNER/REPO --json reviews,reviewThreads
   ```
3. Present a summary to the user:
   ```
   ✅ Copilot finished reviewing PR #123!

   Review state: CHANGES_REQUESTED

   Comments:
   1. src/auth.ts:42 - Consider using constant-time comparison for token validation
   2. src/api.ts:15 - Missing error handling for network timeout

   Would you like me to address these comments?
   ```
4. **Ask the user** before making any changes — do not auto-fix

When `read_bash` returns output containing `TIMEOUT`:
- Notify the user that the review hasn't arrived
- Offer to keep watching or stop

### Step 5: Address Review Comments (if requested)

If the user asks to fix the comments:

1. Fetch the full review threads with file paths and line numbers:
   ```bash
   gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments \
     --jq '.[] | select(.user.login | test("^(copilot|copilot-pull-request-reviewer(\\[bot\\])?|github-copilot\\[bot\\])$")) | {path, line, body, diff_hunk}'
   ```
2. Read each referenced file
3. Make the suggested fixes
4. Present the changes for user approval before committing

## Error Handling

### PR Not Found
```bash
if ! gh pr view "$PR_NUMBER" --repo "$REPO" &>/dev/null; then
    echo "❌ PR #$PR_NUMBER not found in $REPO"
    exit 1
fi
```

### Not Authenticated
```bash
if ! gh auth status &>/dev/null; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi
```

### Script Already Running
Before launching a new watcher, check if one is already active for this PR:
```bash
# The agent should track the shellId and avoid launching duplicates
```

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| Polling interval | 30s | How often the shell script checks for the review |
| Timeout | 3600s (1hr) | Maximum time to wait before giving up |
| read_bash delay | 120s | How often the agent checks the script output |

## Boundaries

**Will:**
- Monitor for Copilot code review completion on GitHub PRs
- Run as a background shell script (zero tokens while polling)
- Present review comments to the user
- Address review comments when the user asks

**Will Not:**
- Auto-fix review comments without user confirmation
- Monitor non-Copilot reviews (use for human reviewer watching is out of scope)
- Work outside the `gh` CLI ecosystem
- Poll indefinitely (respects timeout)

## Integration with Other Skills

| Skill | When to Combine |
|-------|-----------------|
| watch-ci | Watch both CI and code review simultaneously after pushing a PR |
| notify-me | Send a Slack DM when the review lands (if notify-me skill is available) |

## References

- [`references/polling-technique.md`](references/polling-technique.md) — why the async shell + `read_bash` pattern yields zero-token waiting.
- [`examples/basic-usage.md`](examples/basic-usage.md) — a basic Copilot-review watch flow, including timeout handling and the combined CI watcher.
