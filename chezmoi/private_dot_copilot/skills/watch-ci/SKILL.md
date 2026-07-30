---
description: Use when the user wants background monitoring of GitHub Actions workflow runs, status checks, or CI/CD pipelines — phrases like "watch CI", "monitor checks", "alert when CI passes", "alert when CI fails", "watch build status", "let me know when it's green", "monitor PR checks", "keep an eye on CI", "watch for failures".
metadata:
    github-path: skills/watch-ci
    github-ref: refs/heads/main
    github-repo: https://github.com/github/agent-config
    github-tree-sha: d10632c1315279bb5849c45550b36902b486fbba
name: watch-ci
---
# Watch CI — zero-token background monitoring of GitHub checks

Monitors GitHub Actions checks / status checks on a PR (or branch) and wakes the agent only when they finish, fail, or need attention. While the poll runs the agent consumes **zero LLM tokens** — the work happens in a shell launched via `bash(mode="async")`, and the agent checks back with `read_bash`. The runtime also posts a completion notification when the shell exits, so the user gets pinged without the agent burning turns.

This skill is *raw check monitoring only*. For the full review/CI/merge loop (address feedback, re-request CCR, resolve conflicts, loop to clean) use `manage-pr` — it delegates the CI-watching half to this skill. To wait on a Copilot *review* rather than checks, use `wait-for-copilot-code-review` and run the two watchers in parallel.

## When to Use This Skill

- "Watch CI", "let me know when it's green", "alert me if it fails".
- After pushing, monitor checks without blocking the session.
- "Auto-merge when green" — but only act on the merge when the user explicitly asks for it.
- Watch several PRs at once.

## Core mechanism — the zero-token poll

`gh pr checks <pr> --watch` blocks until every check reaches a terminal state, then exits `0` (all watched checks passed) or non-zero (something failed or timed out), printing the final table. Launch it via `bash(mode="async")` and read it back with a long `read_bash` delay — the LLM is not invoked while it waits.

```
turn 1: bash(mode="async")  → gh pr checks <pr> --required --watch → returns shellId
turn 2: read_bash(shellId, delay=120) → still running → empty output
turn 3: read_bash(shellId, delay=120) → final table + exit code → agent resumes
```

This is the same pattern `wait-for-copilot-code-review` uses; the two compose — launch both async in one turn, then `read_bash` each.

## Step 1: Identify what to watch

Priority order:
1. Explicit PR number from the user.
2. The current branch's PR: `gh pr view --json number,headRefOid -q '.number'`.
3. A specific workflow run id if the user gave one (`gh run watch <run-id>` instead of `gh pr checks`).

Guard before launching — a fast fail beats a silent 1-hour no-op:

```bash
gh auth status >/dev/null 2>&1 || { echo "❌ not authenticated (gh auth login)"; exit 1; }
gh pr view "$PR" --repo "$OWNER/$REPO" >/dev/null 2>&1 || { echo "❌ PR #$PR not found in $OWNER/$REPO"; exit 1; }
```

## Step 2: Launch the watcher (async, zero-token)

```bash
gh pr checks "$PR" --repo "$OWNER/$REPO" --required --fail-fast --watch --interval 30
```

Launch this with `bash(mode="async")` and keep the `shellId`.

- `--required` keeps advisory/optional checks from gating the verdict. Drop it if the user wants *all* checks.
- `--fail-fast` returns on the first failure instead of waiting for the rest — usually what you want, since one red required check already blocks merge.
- If the PR has **no checks configured**, `gh pr checks` exits non-zero immediately with "no checks reported"; surface that as "no CI on this PR" rather than a failure.

## Step 3: Wait with `read_bash`

```
read_bash(shellId, delay=120)
```

Checks commonly take 5–30 min. Start at `delay=120`; if output is empty, call `read_bash` again. The shell does its own polling at `--interval`; the `read_bash` delay only controls how often the agent peeks. If a check is genuinely stuck, `stop_bash` the watcher rather than waiting forever.

## Step 4: Report the result

**Exit 0 (green):**
```
✅ All required checks passed on <owner>/<repo>#<PR>
```
Then offer the next step that fits the PR state — "ready to merge", "still waiting on review approval", or auto-merge if the user asked for it.

**Non-zero (red):** show which checks failed and the log command — don't auto-fix.
```bash
gh pr checks "$PR" --repo "$OWNER/$REPO"                 # which check failed + its run URL
gh run view "$RUN_ID" --repo "$OWNER/$REPO" --log-failed # failing job logs
```
Offer to analyze the failure or re-run failed jobs (`gh run rerun "$RUN_ID" --failed`). Re-run only on request.

### Known github/github flakes (not merge blockers)

On `github/github` specifically, some red checks are infrastructure flakes, not code failures. Recognize these before treating a red as real, and offer a retry rather than a code fix:

| Failing signal | Why it's a flake | Action |
| --- | --- | --- |
| `non-required-golden-jobs (github-gauntlet, …)` failing with `GitHub::DGit::ThreepcError` (from PR-factory ref creation, e.g. `Git::Ref#create`) | github-gauntlet is a **non-required** flaky-test-surfacing job; the ThreepcError is test-infra flake from the PR factory, not your diff. | Not a merge blocker (non-required). Retry, or apply the **`Skip gauntlet suite`** label. |
| Any job (e.g. `enterprise-N`) failing at Docker-registry login with `Failed to login to octofactory-ang.githubapp.com … net/http: TLS handshake timeout` | Transient infra failure at the image-pull/login step, before any tests run. | Retry the failed job: `gh run rerun "$RUN_ID" --failed`. |

These patterns are `github/github`-specific. On other repos, treat red as red.

## Auto-merge on green (only when explicitly requested)

```bash
gh pr merge "$PR" --repo "$OWNER/$REPO" --squash --auto --delete-branch
```

`--auto` lets the merge queue / branch protection land it once checks pass, so it composes with the watcher. Never merge unless the user asked for it in this request.

## Multiple PRs

Launch one async watcher per PR in the same turn, track each `shellId`, and report each as it finishes:

```bash
# one bash(mode="async") call per PR
gh pr checks "$PR" --repo "$OWNER/$REPO" --required --fail-fast --watch --interval 30
```

## Boundaries

**Will:**
- Monitor GitHub Actions checks / status checks on a PR or branch.
- Run as a zero-token async shell poll by default; rely on the runtime's completion notification.
- Surface pass/fail with the failing checks and the log command.
- Handle several PRs at once.
- Auto-merge **only** when the user explicitly asks.

**Will Not:**
- Block the foreground session while checks run.
- Monitor non-GitHub CI systems.
- Auto-fix failures or re-run jobs without being asked.
- Merge without an explicit request.

## Related Skills

- `manage-pr` — full review/CI/merge orchestration; delegates CI-watching here.
- `wait-for-copilot-code-review` — zero-token wait for a CCR pass; run in parallel with this.
