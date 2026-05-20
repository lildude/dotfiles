# Copilot Code Review (CCR) — quirks and recipes

This is the field guide for triggering and waiting on **Copilot Code Review** (the `copilot-pull-request-reviewer[bot]` GitHub App). Most of these were learned the hard way during real PR iteration.

## The reviewer-login gotcha

There are two valid logins you can pass to `POST /repos/{o}/{r}/pulls/{n}/requested_reviewers`:

| Login | Effect |
|---|---|
| `Copilot` | Works for the **first** review on a PR. After CCR has reviewed at least once, this form gets silently no-op'd by GitHub (returns 201 but with `requested_reviewers: []`). |
| `copilot-pull-request-reviewer[bot]` | Goes through the **re-request** path. Works whether or not CCR has reviewed before. |

**Always use the `[bot]`-suffixed form.** It's verbose but correct in every state.

```bash
gh api repos/$OWNER/$REPO/pulls/$PR/requested_reviewers -X POST \
  -f 'reviewers[]=copilot-pull-request-reviewer[bot]'
```

In some shells the `[` and `]` need to be quoted (in `gh api -f` they don't — `gh` doesn't shell-expand the value).

## Always verify the request landed

The POST returns 201 in both the "queued" and "silently dropped" cases. Verify by reading the PR back:

```bash
gh api repos/$OWNER/$REPO/pulls/$PR --jq '.requested_reviewers[].login'
```

If the output is empty, your request was dropped. Common reasons:

- You used the plain `Copilot` form on a re-request (use `copilot-pull-request-reviewer[bot]`).
- The bot is mid-review on the same SHA (wait for the in-progress workflow to complete and try again).
- A workflow event triggered an auto-review that's already queued (check the Actions tab).

## The workflow you're waiting for

The CCR workflow run shows up under Actions with the name `Running Copilot Code Review`. It runs against a specific commit SHA. To check status:

```bash
SHA=$(git rev-parse HEAD)
gh api repos/$OWNER/$REPO/actions/runs --jq \
  ".workflow_runs[] | select(.name==\"Running Copilot Code Review\") |
   select(.head_sha | startswith(\"$SHA\")) | {status, conclusion, created_at}"
```

`status` transitions: `queued` → `in_progress` → `completed`. The actual review (and `pull_request_review` event) usually arrives 30s–2 min after `completed`.

## Polling pattern

A drop-in poll loop that surfaces progress without going silent:

```bash
SHA=$(git rev-parse HEAD)
for i in $(seq 1 30); do
  run=$(gh api repos/$OWNER/$REPO/actions/runs --jq \
    ".workflow_runs[] | select(.name==\"Running Copilot Code Review\") |
     select(.head_sha | startswith(\"$SHA\")) | .status" | head -1)
  if [ -z "$run" ]; then
    [ $((i % 4)) -eq 1 ] && echo "$(date +%H:%M:%S) (no CCR run yet)"
  else
    echo "$(date +%H:%M:%S) CCR: $run"
    [ "$run" = "completed" ] && break
  fi
  sleep 30
done
```

Cap your poll at 15–20 min. If the workflow hasn't even shown up by then, something is wrong — surface that to the user instead of polling forever.

## Reading the review back

CCR submits a single `COMMENTED` review per pass and an issue comment with a verdict like "Copilot thinks this PR is not ready to approve". Pull both:

```bash
# Review comments (line-anchored findings, the actionable ones)
gh api graphql -f query='
query($o:String!,$r:String!,$n:Int!){
  repository(owner:$o,name:$r){pullRequest(number:$n){
    reviewThreads(first:50){nodes{
      id isResolved
      comments(last:1){nodes{databaseId path line body author{login}}}
    }}
  }}
}' -f o="$OWNER" -f r="$REPO" -F n="$PR" \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[]
        | select(.isResolved==false)
        | {id, dbId: .comments.nodes[0].databaseId, path: .comments.nodes[0].path,
           line: .comments.nodes[0].line, body: .comments.nodes[0].body}'

# Verdict (auto-approve experiment comment from the Copilot app)
gh api repos/$OWNER/$REPO/issues/$PR/comments \
  --jq '[.[] | select(.user.login=="Copilot")] | .[-1].body'
```

## Per-PR cooldown signal

CCR has an apparent per-PR debounce. If you push a new commit within ~2 minutes of the previous CCR review completing, the auto-trigger may skip your push entirely (no `Running Copilot Code Review` workflow appears for the new SHA). Workarounds:

1. **Wait** — the cooldown clears in ~10–20 minutes.
2. **Explicitly re-request** with `copilot-pull-request-reviewer[bot]` — this bypasses the auto-trigger debounce.

Don't try to push an empty commit to force a re-trigger; it doesn't reliably work and adds noise.

### Always verify CCR reviewed the *latest* SHA

The cooldown above means a clean PR snapshot (`0 unresolved threads`, all CI green) is **not** sufficient evidence that CCR actually weighed in on what's currently on the branch. CCR may simply have skipped that push. Before declaring a PR clean, check:

```bash
HEAD=$(gh api repos/$OWNER/$REPO/pulls/$PR --jq '.head.sha')
LATEST_CCR=$(gh api repos/$OWNER/$REPO/pulls/$PR/reviews --jq \
  '[.[] | select(.user.login=="copilot-pull-request-reviewer[bot]")] | last | .commit_id')

if [ "$HEAD" != "$LATEST_CCR" ]; then
  echo "⚠️  CCR has not reviewed the head commit ($HEAD; latest CCR review was on $LATEST_CCR)"
  # Re-request:
  gh api repos/$OWNER/$REPO/pulls/$PR/requested_reviewers -X POST \
    -f 'reviewers[]=copilot-pull-request-reviewer[bot]'
fi
```

Symptom this catches: you fix the last review's findings, push, see no new CCR review for an hour, and assume CCR ran and was happy. In reality CCR never even fired on your push — and the auto-approve verdict comment you might be reading is from the *previous* SHA. Always cross-reference `head.sha` against the latest CCR review's `commit_id`.

## Author association in `requested_reviewers`

When the `[bot]`-suffixed login succeeds, the resulting `requested_reviewers` entry shows up with `login: "Copilot"` (no suffix) — this is GitHub's display normalization. Don't be confused; it's the same bot.
