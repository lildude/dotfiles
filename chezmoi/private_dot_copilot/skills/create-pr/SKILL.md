---
name: create-pr
description: This skill should be used when the user asks to "create a PR", "open a draft PR", "send a pull request", "push this and open a PR", or any variant that ends in a new pull request. Encodes hard-won conventions for working in the github/github monolith and other GitHub repos that ship code via PR — most importantly using a worktree to avoid colliding with the user's inflight branches and using the repo's PR template format for the body so the PR doesn't get bounced for missing fields.
---

# Create PR — open a high-quality pull request the user won't have to fix up

Use this skill any time the work you're doing for the user ends in a new pull request. The mechanics of creating a PR are simple, but there are conventions that, if skipped, force the user to redo work or get the PR bounced in review.

## When to Use This Skill

- "Create a draft PR for this change"
- "Push this and open a PR"
- "Send a pull request"
- "Open a PR with these fixes"
- Any request that implies a code change → branch → PR end state

If the user is asking you to *iterate* on an already-open PR (address comments, re-request review, wait for CI), use the `manage-pr` skill instead.

## Workflow

### 1. Use a worktree, not a branch in their existing checkout

The user is almost always working on something else in their primary checkout. Creating a branch there and switching files out from under them is extremely disruptive and a frequent source of complaints.

Default behavior: **always create a git worktree for the new branch** unless the user explicitly says otherwise.

```bash
# Confirm we're starting from latest origin
cd /path/to/their/repo
git fetch origin <default-branch> --quiet

# Create the worktree as a sibling directory
git worktree add -b <user>/<short-description> ../<repo-name>-<short-description> origin/<default-branch>
cd ../<repo-name>-<short-description>
```

Naming conventions:
- Branch: `<user>/<kebab-case-description>` (e.g. `obvioussean/hydro-publish-success-counter`)
- Worktree directory: `<repo-name>-<short-description>` as a sibling of the original checkout

After the work is done, leave the worktree in place (the user can clean up later with `git worktree remove`). Don't delete it as part of "finishing."

### 2. Check for and use the repo's PR template

Every serious GitHub repo has a PR template. If you skip it, the PR will be missing required sections (risk assessment, environments, mitigation strategy, validation method) and reviewers will bounce it.

```bash
ls .github/PULL_REQUEST_TEMPLATE* .github/pull_request_template* 2>/dev/null
# also check .github/PULL_REQUEST_TEMPLATE/ subdirectory
```

If a template exists, **read it** and fill in every section that applies. Do not invent your own structure.

For `github/github` specifically, the template requires:
- A summary paragraph at the top (no heading)
- `### What approach did you choose and why?` (with optional sub-bullets for Tradeoffs / Risk / Alternatives / Attention / Observability / Accessibility)
- `### Which feature flags are involved in this change?`
- `### Which environments does this change target?` (bulleted list, delete what doesn't apply)
- `### Risk assessment` (pick **Low risk** or **High risk**, justify it)
- `### How did/will you validate this change?` (Review-lab, Local server, Tests, Other, None)
- `### Are there related full stack changes?` (No / Yes with sub-bullets)
- `### If something goes wrong, what are the mitigation and rollback strategies?` (Other / Experiment / Solo Deploy / Feature Flag / Rollback)

The HTML comments in `.github/pull_request_template.md` map to PR labels via `.github/workflows/label_pr_from_template.yml`. Keep heading text exact so labels apply correctly.

See `references/template-formats.md` for examples and field-by-field guidance.

### 3. Write a good commit message

A good commit message answers "why" not just "what". Multi-line commits are fine and preferred for non-trivial changes:

```bash
git commit -m "<short imperative summary, ~50 chars>

<wrapped body explaining motivation, what changed, and what didn't change.
Tie it back to the user-visible problem if there is one.>

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

Always include the Copilot Co-authored-by trailer.

### 4. Push the branch

```bash
git push -u origin <user>/<short-description>
```

If push fails because the branch already exists upstream from a prior session, ask the user before force-pushing.

### 5. Run linters/tests if the dev environment is available

In a full checkout:
```bash
bin/rubocop path/to/changed.rb
bin/srb tc path/to/changed.rb
bin/rails test path/to/changed_test.rb
```

In a worktree without `bin/` (no dev container), explicitly tell the user you didn't run them locally and that CI will validate. Do not pretend you ran them.

### 6. Create the PR (draft by default)

Use `--body-file` for non-trivial bodies — `--body` with multi-line strings is brittle in shell. **Always create a unique per-PR temp directory** so there's zero chance of collision with concurrent work, stale `gh` state, or another agent reading the wrong body file:

```bash
PR_TMP=$(mktemp -d -t pr-body-XXXXXX)
cat > "$PR_TMP/body.md" <<'EOF'
<full template-formatted body>
EOF
gh pr create --draft \
  --base <default-branch> \
  --head <user>/<short-description> \
  --title "<short imperative title — usually mirrors the commit summary>" \
  --body-file "$PR_TMP/body.md"

# Verify the body actually landed (gh has been observed silently substituting
# bodies from cached state when it doesn't like the input — see Pitfalls):
gh pr view <number> --json body --jq .body | head -3

rm -rf "$PR_TMP"
```

Default to `--draft` unless the user explicitly says "ready" or "open" (not draft). Drafts can always be marked ready, but a non-draft PR triggers reviewer notifications immediately.

### 7. Report back with the URL and what's in it

After the PR is created, report:
- The PR URL
- The worktree path and branch name
- The diff size (files changed, +/- lines)
- Whether tests/linters were run locally or deferred to CI
- Any deliberate non-goals you flagged in the PR body

## Common Pitfalls

- **Creating a branch in the user's primary checkout.** Always use a worktree unless told otherwise.
- **Skipping the template.** Costs the user a round-trip and a re-edit. Always check `.github/`.
- **Inventing template sections.** If `.github/pull_request_template.md` says `### Risk assessment`, use those exact words. The labeling workflow keys off them.
- **Opening the PR non-draft by default.** This pings reviewers immediately and can't be undone gracefully. Default to draft.
- **Multi-line `--body` arguments.** Use `--body-file` for anything past 2-3 lines; quoting and escaping are unreliable across shells.
- **Reusing predictable `/tmp` paths** like `/tmp/pr-body.md`. Always `mktemp -d` a fresh directory per PR (e.g. `/tmp/pr-body-XXXXXX/body.md`). A predictable path can collide with concurrent work or — observed in practice — `gh pr create` silently substituting the body from elsewhere when it can't read the file you specified, producing a PR with someone else's content. Verify the body landed with `gh pr view <n> --json body` before walking away.
- **Pretending you ran tests when you didn't.** If the worktree doesn't have `bin/`, say so explicitly.
- **Forgetting the Co-authored-by trailer** on commits and PR bodies.
- **Bare `#N` for cross-repo references.** GitHub's autolinker resolves bare `#N` to the *same* repo only — so `#607` in a `github/github` PR body silently links to `github/github#607`, not the cross-repo issue you meant. Always use `owner/repo#N` (or a full URL) when referencing an issue/PR in a different repo. This is especially important when the prompt drives a cloud agent that authors the PR body — the prompt must spell out the fully-qualified form, since the agent will copy whatever style you give it.

## Boundaries

This skill stops at "PR is open and reported back to the user." Driving the PR through review, addressing comments, re-requesting Copilot review, and waiting for CI all live in the `manage-pr` skill.
