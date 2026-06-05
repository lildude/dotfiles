---
name: manage-pr
description: This skill should be used when the user asks to "address PR feedback", "respond to review comments", "request a Copilot code review", "watch CI", "wait for CI", "iterate on a PR until clean", or needs to drive a pull request through the review/CI/merge loop.
---

# Manage PR — drive a pull request through review and CI to clean

Use this skill any time you're shepherding a PR through to merge: addressing reviewer comments, requesting a fresh Copilot Code Review (CCR) pass, waiting for CI, and looping until the PR is clean.

The CLI primitives are simple but there are several surprising behaviors that this skill captures so you don't have to rediscover them:

- The right reviewer login to re-request CCR is `copilot-pull-request-reviewer[bot]`, **not** plain `Copilot` (see `references/copilot-code-review.md`).
- A successful re-request POST returns 201 even when GitHub silently no-ops it; you must verify by re-reading the PR.
- CCR runs are tied to a specific commit SHA; you can't trigger a fresh review without either a new push or a successful re-request.

## ⚡ Always run this skill as a background agent

This skill polls CI and CCR until the PR is clean. CI alone can take 30+ minutes; the full review/iterate loop can take hours across multiple CCR rounds. **Blocking the user's main session for that long is wrong.**

When invoking this skill, **always launch it as a `task` background agent** so the user keeps their session free for follow-ups:

```
task tool with:
  agent_type: general-purpose
  mode: background
  name: manage-pr-<short>
  prompt: "Run the manage-pr skill on <repo>#<number>. Address review feedback,
           re-request CCR as needed, watch CI, loop until clean. Notify me
           when done or when you hit a blocker that needs my judgment."
```

Exceptions where it's fine to run inline:
- The user explicitly says "stay foreground" / "wait with me" / "don't background this"
- The PR is **already** in a final state and you only need a one-shot snapshot (no looping) — in that case, the work is short and the snapshot output is the actual answer the user wants

In every other case: launch as a background agent, hand the agent_id back to the user with a one-line note, and end your turn. The user will get a system notification when the background agent completes.

When you (the background agent) finish, surface a final-state summary including: which threads were addressed, which (if any) were left for the user, the head SHA + final CCR verdict, the final CI rollup, and the merge-state status. If you hit a blocker that needs human judgment (ambiguous reviewer feedback, complex merge conflict, unexplained test failure that smells unrelated to the change), stop polling and surface the question — don't keep looping while waiting on a decision.

## When to Use This Skill

- "Address all the open review comments on PR #123."
- "Re-request Copilot review on this PR."
- "Wait for CI to finish and tell me what's failing."
- "Loop on this PR — fix the review feedback and the CI failures until it's all green."
- "What's the state of PR #123? What's left to address?"
- "Make PR #123 mergeable" / "make it green" / "drive this to merge" — orchestrate everything (conflict resolution, review, CI) until the PR can land.

If the user just wants raw CI monitoring (no review-comment work), prefer the `watch-ci` skill. If they just want a single CCR review wait, prefer `wait-for-copilot-code-review`. Use this skill when they want orchestration across all of the above.

## Process

### Step 1: Snapshot the PR

Always start with one summary call so you know what you're working with:

```bash
OWNER=...; REPO=...; PR=...
gh api graphql -f query='
query($o:String!,$r:String!,$n:Int!){
  repository(owner:$o,name:$r){
    pullRequest(number:$n){
      number title state isDraft mergeable mergeStateStatus
      headRefOid baseRefName
      reviewThreads(first:50){
        nodes{
          id isResolved isOutdated
          comments(last:1){nodes{databaseId path line body author{login}}}
        }
      }
      commits(last:1){nodes{commit{statusCheckRollup{state contexts(first:50){nodes{
        ... on CheckRun{name conclusion status detailsUrl}
        ... on StatusContext{context state targetUrl}
      }}}}}}
    }
  }
}' -f o="$OWNER" -f r="$REPO" -F n="$PR"
```

From this you can extract everything you need: head SHA, unresolved threads with full bodies, CI status, mergeability.

**Always also check whether CCR has reviewed the head SHA**, not just whether unresolved threads exist. The per-PR cooldown can cause CCR to silently skip a push, leaving you with a "clean" snapshot that hasn't actually been re-reviewed:

```bash
HEAD=$(gh api repos/$OWNER/$REPO/pulls/$PR --jq '.head.sha')
LATEST_CCR=$(gh api repos/$OWNER/$REPO/pulls/$PR/reviews --jq \
  '[.[] | select(.user.login=="copilot-pull-request-reviewer[bot]")] | last | .commit_id // ""')
if [ "$HEAD" != "$LATEST_CCR" ] && [ -n "$LATEST_CCR" ]; then
  echo "⚠️  CCR has not reviewed head ($HEAD); latest review was on $LATEST_CCR"
fi
```

If the head SHA isn't reviewed yet, treat the snapshot as "pending CCR" and re-request before declaring the PR clean. See `references/copilot-code-review.md` for the full pattern.

### Step 2: Resolve merge conflicts (if `mergeStateStatus == DIRTY` or `mergeable == CONFLICTING`)

Before doing any other work, check the snapshot's `mergeable` / `mergeStateStatus`. If **either** `mergeStateStatus == DIRTY` **or** `mergeable == CONFLICTING` (equivalently `mergeable_state == "dirty"` from the REST API), the PR has conflicts with its base branch and **cannot merge no matter how green CI is or how many approvals it has**. Resolve before continuing.

Check both fields, not just one. GitHub computes them asynchronously, so a fresh snapshot can briefly return `mergeStateStatus == UNKNOWN` while `mergeable` is already `CONFLICTING` — keying off only `DIRTY` would skip conflict resolution on exactly the kind of PR this step exists to catch. Same applies in reverse.

Don't skip this check just because checks are passing. A conflicting PR with all-green CI looks "ready" but isn't — that's the trap this step exists to prevent.

```bash
# Pull the PR's actual base branch out of the snapshot — DO NOT assume it's
# the repo default. Release-branch and stacked PRs target non-default bases,
# and merging the wrong branch creates a misleading merge commit while
# leaving the PR unmergeable.
BASE=$(gh api repos/$OWNER/$REPO/pulls/$PR --jq '.base.ref')
HEAD_BRANCH=$(gh api repos/$OWNER/$REPO/pulls/$PR --jq '.head.ref')

# Find the local worktree for this branch. Typical pattern is
# ~/Repos/<repo>-<short-description>; the description usually echoes part
# of $HEAD_BRANCH. Use grep -F so branch names containing regex
# metacharacters (., +, (, |, etc.) match literally instead of as regex.
ls -d ~/Repos/${REPO}* 2>/dev/null | grep -iF -- "${HEAD_BRANCH##*/}" || ls -d ~/Repos/${REPO}* 2>/dev/null

cd ~/Repos/<the-worktree>
git fetch origin "$BASE" --quiet
git merge "origin/$BASE" --no-edit
# → resolve conflicts; the conflict is usually small and the user's intent
#   from their PR usually decides which side wins.
```

After resolving:

1. Run the project's local validation — at minimum a build and the tests touching the conflict area. For Go repos: `go build ./... && go vet ./... && go test -race ./<affected packages>/...`. For others, follow the repo's `AGENTS.md` / `CONTRIBUTING.md`.
2. `git add -A && git commit --no-edit` (the merge commit message is fine), then `git push`.
3. Re-snapshot (Step 1) and continue with the rest of the loop. The new merge commit will trigger fresh CI; re-request CCR on the new head SHA per Step 5.

If the conflict is non-trivial or the user's intent is ambiguous, **stop and ask** rather than guessing — picking the wrong side of a conflict can silently revert the PR's actual change.

### Step 3: Address feedback

For each unresolved thread:

1. Read the comment body (`comments(last:1).nodes[0].body`) and the path/line.
2. Apply the fix in the working copy.
3. Decide: agree with the comment, push back with reasoning, or partially apply.

When you have one or more fixes ready, commit them with a meaningful message and push:

```bash
git add -A
git commit -m "$MESSAGE

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
git push
```

A single commit can address multiple threads — group related fixes.

### Step 4: Reply to and resolve each addressed thread

For every thread you addressed, post a reply explaining the fix (referencing the commit SHA), then resolve the thread. Threads that you did **not** address (or where you disagreed) should get a reply explaining why; resolve only after you and the reviewer agree.

```bash
# Reply
gh api repos/$OWNER/$REPO/pulls/$PR/comments -X POST \
  -f body="Fixed in $SHA — <one-line explanation>" \
  -F in_reply_to="$COMMENT_DATABASE_ID"

# Resolve (use the thread node ID from the GraphQL snapshot)
gh api graphql \
  -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' \
  -f id="$THREAD_NODE_ID"
```

You can do all of these in a single bash loop — see `references/bulk-resolve.md` for a ready-to-paste template.

### Step 5: Request (or re-request) Copilot Code Review

CCR usually fires automatically on push events, but on long-running PRs it can be debounced. To explicitly request or re-request:

```bash
gh api repos/$OWNER/$REPO/pulls/$PR/requested_reviewers -X POST \
  -f 'reviewers[]=copilot-pull-request-reviewer[bot]'
```

⚠️ **Critical gotcha**: use `copilot-pull-request-reviewer[bot]`, **not** `Copilot`. The plain `Copilot` form works for the *first* review on a PR but is silently no-op'd on re-requests after the bot has already reviewed. The `[bot]`-suffixed login goes through the re-request path. See `references/copilot-code-review.md` for the full story.

Always **verify the request landed** by reading the PR back:

```bash
gh api repos/$OWNER/$REPO/pulls/$PR --jq '.requested_reviewers[].login'
```

If the array is empty after the POST, the request was dropped — do not assume it queued.

### Step 6: Watch CI and wait for the new CCR review

After pushing, hand off the polling work to the dedicated skills — both support background mode so the user can keep working:

- **CI checks**: invoke the `watch-ci` skill on the head SHA. It runs a zero-token shell poll and surfaces pass/fail when checks complete.
- **CCR review**: invoke the `wait-for-copilot-code-review` skill. It polls for a new CCR review on the head SHA without burning LLM turns and wakes back up with the comments.

Run them in parallel. Don't inline a polling loop here — that re-implements what those skills already encode (and skips their background-mode benefit).

The CCR review usually appears 1–3 minutes after the `Running Copilot Code Review` workflow completes; `wait-for-copilot-code-review` already knows to look for that.

### Step 7: Loop

Re-snapshot (Step 1). If `mergeStateStatus == DIRTY` or `mergeable == CONFLICTING` (check both — see Step 2 for the async-computation rationale), go back to Step 2. If there are unresolved threads or failing checks, go back to Step 3. Repeat until **all** of these hold:

- 0 unresolved review threads
- `mergeStateStatus` is `CLEAN` (or `BLOCKED` only on policy items the user is choosing to bypass) **and** `mergeable` is `MERGEABLE` (not `CONFLICTING`). Symmetric with the loop trigger above — if either field still says the PR is conflicting, treat it as still-conflicting and go back to Step 2. If either field is `UNKNOWN`, GitHub is still computing; re-snapshot in a few seconds rather than declaring victory.
- All status checks `SUCCESS`
- The latest CCR-bot review's `commit_id` matches the current `head.sha` (i.e. CCR has actually reviewed the most recent push, not just an earlier one — see Step 1's CCR-coverage check)

If the first three are true but CCR hasn't reviewed the head SHA, **re-request** rather than declaring victory. The auto-approve verdict comment you may be reading might be from the previous SHA; only treat the PR as approved when CCR's review references the current head.

Then surface a one-line "ready to merge" summary to the user and stop.

## Output Format

For each iteration, give the user a compact status snapshot before doing more work:

```text
PR #289 — slack-search skill
  head:       830f66a (1 commit ahead of last review)
  reviews:    3 unresolved threads (all from copilot-pull-request-reviewer)
  CI:         3 of 7 checks completed (all passing so far)
  mergeable:  blocked on review

Plan:
  1. Address the unresolved threads in 830f66a (script + 1 doc fix)
  2. Push; re-request Copilot review
  3. Wait for CCR + remaining CI
```

## Boundaries

**Will:**
- **Run as a background agent by default** so the user's main session stays free.
- Snapshot PR state (threads, CI, mergeability) in one read.
- Apply fixes for review comments and group them into meaningful commits.
- Reply to and resolve threads (only resolves threads you actually addressed or that the reviewer agreed to drop).
- Request and re-request Copilot Code Review using the correct `[bot]` login form.
- Verify each re-request landed (the API silently drops some).
- Poll CI and CCR workflow status; surface failures.
- Loop until clean, or hand back to the user when blocked.
- Surface a final-state summary on completion (or partial progress if blocked) so the user can act on it without re-querying the PR.

**Will Not:**
- **Block the foreground session waiting for CI / CCR.** Always run as a background agent unless the user explicitly opts out.
- Resolve a thread you didn't address (or that the reviewer hasn't agreed to drop).
- Push fixes that contradict reviewer feedback without explicit user approval.
- Force-merge or override branch protection.
- Keep polling silently for hours when blocked on a human decision — surface the question and stop.

## References

- [`references/copilot-code-review.md`](references/copilot-code-review.md) — The CCR re-request gotcha, workflow timing, and how to debug "review never fires".
- [`references/bulk-resolve.md`](references/bulk-resolve.md) — Bash template for replying to + resolving N threads in one pass.
- [`references/gh-pr-snippets.md`](references/gh-pr-snippets.md) — Copy-pasteable `gh api` commands for the common PR queries.

## Related Skills

- `watch-ci` — focused CI-only monitoring with notifications on completion.
- `wait-for-copilot-code-review` — zero-token polling for a single CCR pass.
- `slack-search` — pull related Slack discussion when a review comment references chat context.
