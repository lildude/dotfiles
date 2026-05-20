# Bulk reply + resolve template

Use this when you've addressed N review threads in a single commit and want to reply to and resolve all of them in one pass.

## Inputs

- `OWNER`, `REPO`, `PR` — the PR coordinates.
- `SHA` — the commit SHA that addresses the threads (usually `$(git rev-parse HEAD)`).
- For each thread:
  - `thread_id` — GraphQL node ID (looks like `PRRT_kwDO...`)
  - `comment_db_id` — REST `databaseId` integer
  - `body` — your reply text

## Template

```bash
OWNER=github
REPO=agent-skills
PR=289
SHA=$(git rev-parse HEAD)

reply() {
  # $1 = REST databaseId of the comment to reply under
  # $2 = reply body
  gh api repos/$OWNER/$REPO/pulls/$PR/comments -X POST \
    -f body="$2" -F in_reply_to="$1" --jq '.id' > /dev/null
}

resolve() {
  # $1 = GraphQL thread node ID
  gh api graphql \
    -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' \
    -f id="$1" --jq '.data.resolveReviewThread.thread.isResolved' > /dev/null
}

# 1. Auth_preflight unused return value
reply 3162052813 "Fixed in $SHA — dropped the unused return value and updated the docstring + references."
resolve "PRRT_kwDORK0ISs5-ehTB"

# 2. gh extension check returncode handling
reply 3162052776 "Fixed in $SHA — check.returncode != 0 is now handled separately and surfaces the actual stderr."
resolve "PRRT_kwDORK0ISs5-ehSm"

# 3. Boundaries DM wording
reply 3162052701 "Reworded in $SHA — boundary is permission inheritance, not a hard-coded DM exclusion."
resolve "PRRT_kwDORK0ISs5-ehR4"
```

## Tips

- Group **all** the addressed threads into one commit when possible — one SHA referenced in many replies is much cleaner for the reviewer than N tiny commits.
- Don't auto-resolve threads you disagreed with or partially declined. Reply, explain, and let the reviewer (or user) make the call.
- If a reply ID needs to include the literal `Co-authored-by:` trailer in the *commit* (not the comment), use `git commit -m "..." -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"` (multiple `-m` create paragraph breaks).

## Getting the IDs you need

The GraphQL snapshot from the main `manage-pr` workflow gives you both:

```graphql
reviewThreads(first:50){
  nodes{
    id                              # → thread_id
    isResolved
    comments(last:1){nodes{
      databaseId                    # → comment_db_id
      path line body author{login}
    }}
  }
}
```

Pull `id` for `resolve()` and `comments.nodes[0].databaseId` for `reply()`.
