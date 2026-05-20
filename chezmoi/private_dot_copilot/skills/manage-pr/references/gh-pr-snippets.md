# gh / gh api PR snippets

Copy-pasteable commands for the queries the `manage-pr` skill uses most.

All snippets assume:

```bash
OWNER=...; REPO=...; PR=...
```

## One-shot PR snapshot (threads + CI + mergeability)

```bash
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
      commits(last:1){nodes{commit{
        statusCheckRollup{
          state
          contexts(first:50){nodes{
            ... on CheckRun{name conclusion status detailsUrl}
            ... on StatusContext{context state targetUrl}
          }}
        }
      }}}
    }
  }
}' -f o="$OWNER" -f r="$REPO" -F n="$PR"
```

## Just the unresolved threads, in addressable form

```bash
gh api graphql -f query='
query($o:String!,$r:String!,$n:Int!){
  repository(owner:$o,name:$r){pullRequest(number:$n){
    reviewThreads(first:50){nodes{
      id isResolved
      comments(last:1){nodes{databaseId path line body author{login}}}
    }}
  }}
}' -f o="$OWNER" -f r="$REPO" -F n="$PR" --jq '
  .data.repository.pullRequest.reviewThreads.nodes[]
  | select(.isResolved==false)
  | {id, dbId: .comments.nodes[0].databaseId,
     path: .comments.nodes[0].path,
     line: .comments.nodes[0].line,
     body: .comments.nodes[0].body}'
```

## CI rollup for the head commit

```bash
SHA=$(gh api repos/$OWNER/$REPO/pulls/$PR --jq '.head.sha')
gh api graphql -f query='
query($o:String!,$r:String!,$sha:GitObjectID!){
  repository(owner:$o,name:$r){object(oid:$sha){
    ... on Commit{statusCheckRollup{
      state
      contexts(first:50){nodes{
        ... on CheckRun{name conclusion status detailsUrl}
      }}
    }}
  }}
}' -f o="$OWNER" -f r="$REPO" -f sha="$SHA"
```

## Workflow runs for a SHA (filter by name)

```bash
gh api repos/$OWNER/$REPO/actions/runs --jq \
  ".workflow_runs[] | select(.head_sha | startswith(\"${SHA:0:7}\"))
   | {name, status, conclusion, created_at, html_url}"
```

## Logs for a failed job

```bash
RUN_ID=...
gh api repos/$OWNER/$REPO/actions/runs/$RUN_ID/jobs --jq \
  '.jobs[] | select(.conclusion=="failure") | {id, name, html_url}'
# Then fetch logs:
JOB_ID=...
gh api repos/$OWNER/$REPO/actions/jobs/$JOB_ID/logs > /tmp/job-$JOB_ID.log
```

## Reply to a review comment (creates an in-thread reply)

```bash
gh api repos/$OWNER/$REPO/pulls/$PR/comments -X POST \
  -f body="..." \
  -F in_reply_to=$COMMENT_DATABASE_ID
```

## Resolve a review thread

```bash
gh api graphql \
  -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' \
  -f id="$THREAD_NODE_ID"
```

## Request (or re-request) Copilot Code Review

```bash
# Use the [bot]-suffixed login. Plain "Copilot" only works the first time.
gh api repos/$OWNER/$REPO/pulls/$PR/requested_reviewers -X POST \
  -f 'reviewers[]=copilot-pull-request-reviewer[bot]'

# Verify it landed
gh api repos/$OWNER/$REPO/pulls/$PR --jq '.requested_reviewers[].login'
```

## Last review by the CCR bot, on a specific SHA

```bash
gh api repos/$OWNER/$REPO/pulls/$PR/reviews --jq \
  ".[] | select(.user.login==\"copilot-pull-request-reviewer[bot]\")
   | select(.commit_id | startswith(\"${SHA:0:7}\"))"
```

## CCR verdict comment (auto-approve experiment)

```bash
gh api repos/$OWNER/$REPO/issues/$PR/comments --jq \
  '[.[] | select(.user.login=="Copilot")] | .[-1].body'
```
