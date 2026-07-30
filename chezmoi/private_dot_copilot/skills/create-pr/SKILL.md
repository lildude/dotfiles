---
description: Use whenever a task is about to end in a new pull request. That covers explicit requests ("create a PR", "open a draft PR", "send a pull request", "push this and open a PR") AND byproduct PRs where the user never said "PR" but the work ends in one (after implementing a fix, removing a feature flag, mirroring another PR, resolving an investigation, etc.). Invoke this skill before running `gh pr create` or pushing a branch to open a PR. Covers github/github monolith and other GitHub repos that ship code via PR.
metadata:
    github-path: skills/create-pr
    github-ref: refs/heads/main
    github-repo: https://github.com/github/agent-config
    github-tree-sha: 3802a183593c55bc6f267dc6049367f75a659ff0
name: create-pr
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

Every serious GitHub repo has a PR template. If you skip it, the PR will be missing sections the repo expects (risk assessment, environments, mitigation/rollback, validation) and reviewers will bounce it.

```bash
ls .github/PULL_REQUEST_TEMPLATE* .github/pull_request_template* 2>/dev/null
# also check .github/PULL_REQUEST_TEMPLATE/ subdirectory
```

If a template exists, **read the live template from the target repo** and fill in every section that applies. Do not invent your own structure, and don't work from a remembered copy — templates change, so the file in the repo is the only source of truth for which sections and headings exist. Fill what applies and delete the options that don't.

Some repos (the monolith among them) drive PR labels off the template: HTML-comment markers next to each option map to labels via a labeling workflow. So copy the headings, option lines, and marker comments **verbatim** from the live template — paraphrasing them silently breaks labeling.

See `references/template-formats.md` for how to read and fill any repo's template, and how to validate label markers, without hardcoding one repo's structure.

**Keep the body concise — the diff already shows the details.** The PR body is the *summary*, not the *inventory*. Reviewers can see file-by-file changes, removed symbols, and line counts in the diff itself; restating them in the body just buries the things the diff *can't* show (motivation, scope boundary, rollout state, rollback plan). Default to a few short paragraphs that fit in one screen.

#### The anti-wall rules

A distilled checklist (adapted from Tom McPhail's PR-description rules) for not shipping a wall of AI-generated text:

- **Lead with why, not what.** The diff already shows the *what*. This is the hardest rule to follow because most templates open with a *what*-flavored heading (e.g. "What approach did you choose…", "What does this change do?"). Don't let the heading order fool you: when the template has a no-heading summary paragraph at the very top, it renders above the first heading and comes first — that's where the why goes. Put the motivation up top and let the *what* heading carry the mechanics.
- **1–3 sentence summary.** If the summary needs more than that, the PR is probably too big — splitting it is the real fix for a wall of text, not better prose.
- **No filler openings.** Never start with "This PR introduces…", "This change ensures…", "In order to…", or "This PR does…". Cut straight to the why.
- **Link the issue, don't re-narrate it.** `Closes #N` (or `owner/repo#N` for cross-repo) *is* the context — don't restate the issue's background in the body.
- **Don't list the files/modules changed.** The diff shows them.
- **A "Notes" section only for genuinely non-obvious decisions, risks, or trade-offs.** Most PRs don't need one.
- **Voice: terse engineer to engineers, not a release announcement.** Informal is fine; slangy isn't.
- **Reach for an ASCII or mermaid diagram** when a flow or architecture is clearer than prose.

Things to **omit** unless the user asks for them:
- File-change stats ("31 files changed, +162/-2947") — visible at a glance in the diff.
- Exhaustive lists of every removed symbol / constant / JSON field / FF / telemetry tag.
- Per-file or per-package "Removed Surface" tables.
- Downstream-consumer matrices with one row per repo.
- **Anything the reviewer can gather by reading the code itself.** This includes "shape matches existing precedent X", "reuses the canonical enum Y", "follows pattern Z used by other consumers", "uses the same struct as W". The diff already shows the field types, the enum reference, the import path, the precedent. Saying it again in prose adds nothing the reviewer didn't already see. Save the prose for the things the code *can't* tell them: why the change exists, what's coordinated elsewhere, what the rollout/rollback looks like.

Things to **always include** (these are what the diff can't tell the reviewer):
- A one-paragraph "why this is safe / why now" (e.g. "FF X has been off on dotcom since DATE").
- Per-FF rollout state if the change is gated, but as a single sentence in the deployment checklist's FF line — not a separate table.
- Cross-repo impact, but as a single sentence per consumer inside the upstream/downstream impact bullets — not a per-repo matrix.

Skip "non-goals" sections. If the diff is genuinely ambiguous about scope, the fix is to tighten the title and the why-paragraph, not to append a list of things you didn't do. Reviewers don't read non-goal lists as scope-bounding; they read them as the author hedging, which adds noise without preventing the misread.

If you find yourself writing tables or per-symbol bullets to *prove you did the work*, keep that material as your own notes (or in the session plan.md) — not in the PR body. The reviewer will trust the diff.

#### Section-by-section conventions

These are the patterns that survive review. Drift from them and the user will rewrite your body:

- **What** — short bullets describing the change. A small mapping table-as-bullets (e.g. `old → new`) is fine. No prose paragraphs explaining what every line does.
- **Why** — the *real* motivation: the user problem this solves, the broken/cosmetic current behavior this fixes, or the value this delivers. **Not** "paired with X" — that's coordination, not motivation. **Not** "this PR does Y" — that's What. If you can't write a Why that stands on its own without referencing sibling PRs, the Why is missing.
- **Coordination** (or **Related**) — its own section listing sibling/cross-repo PRs as bullets with one-line summaries. Always its own section — never jam it into Why.
- **Tests** — a 1-2 sentence summary of *what coverage area* the tests address. **Not** a list of test names. **Not** a narration of each case. Example shape: *"Covers the new tier mapping, unset → default fall-through, and precedence (ExP > effort > FF > default)."* — one sentence describing the coverage, not nine bullets enumerating subtests.
- **Gating** — one short section per FF / staff-flag / rollout knob. Single sentence per flag explaining current state and what role it plays. Skip if the change has no gating story.
- **Rollback** — one section, usually two bullets: the *normal* path (disable an FF, flip a setting) and the *hard* path (revert this PR). Skip if rollback is just "revert."

See [`references/body-examples.md`](references/body-examples.md) for a concrete good/bad comparison.

### 3. Write a good commit message

Default to a **single-line subject** in the same style as the PR title — a lowercase sentence fragment that says what the change does — with one logical change per commit. Add a body **only** when there's a genuinely non-obvious decision, risk, or trade-off the subject can't carry. Most commits don't need one.

```bash
# Most commits: one-line subject, no body (the trailer is a trailer, not a body).
git commit -m "wire review-effort tiers to distinct models

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

When a body *is* warranted, keep it to the why — motivation and the non-obvious trade-off, not a restatement of the diff:

```bash
git commit -m "<lowercase one-line subject>

<short body: only the non-obvious why / risk / trade-off>

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

Always include the Copilot Co-authored-by trailer.

### 4. Push the branch

```bash
git push -u origin <user>/<short-description>
```

If push fails because the branch already exists upstream from a prior session, ask the user before force-pushing.

### 5. Run linters/tests if the dev environment is available

Run whatever linters/tests the repo provides for the files you touched — its `bin/` scripts or the commands its contributing docs list:
```bash
# Examples — use whatever the target repo actually provides:
bin/rubocop path/to/changed.rb        # e.g. a Ruby monolith
bin/rails test path/to/changed_test.rb
```

In a worktree without the repo's dev tooling (no dev container), explicitly tell the user you didn't run them locally and that CI will validate. Do not pretend you ran them.

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
  --title "<lowercase sentence fragment, no feat:/fix(scope): prefixes — mirrors the commit subject>" \
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
- **Verbose PR bodies** — per-file callouts, removed-symbol tables, file-change stats, downstream-consumer matrices. The diff already shows them; they belong in your notes. See section 2's "Keep the body concise."
- **A Why that just says "paired with X"** or lists sibling PRs — that's coordination, not motivation. See section 2's "Section-by-section conventions."
- **A Tests section that enumerates every case.** Summarize the coverage area in 1-2 sentences instead. See section 2's "Section-by-section conventions."
- **An "Opening as draft" / "this is a draft" blurb in the PR body.** The draft state is shown in the PR UI; restating it in the body is filler. Same for "no functional changes" when the diff makes that obvious. If you've added one of these as a hedge, delete it before opening the PR.
- **Rehashing what the code shows** — "matches precedent X", "reuses the canonical enum Y", "follows pattern Z". The diff shows it; cut the sentence. See section 2's "Keep the body concise."
- **Filler openings.** Never open the body with "This PR introduces…", "This change ensures…", "In order to…", or "This PR does…". Lead with the why. See section 2's "anti-wall rules."
- **A summary longer than ~3 sentences.** If it needs more, the PR is probably too big — split it rather than writing more prose. See section 2's "anti-wall rules."
- **`feat:` / `fix(scope):` prefixes (or a Capitalized title).** Titles and commit subjects are plain lowercase sentence fragments that say what the change does. See sections 3 and 6.
- **Re-narrating the linked issue.** `Closes #N` (or `owner/repo#N`) is the context; don't restate the issue's background in the body. See section 2's "anti-wall rules."
- **`gh pr edit` silently failing on a token-scope mismatch.** `gh pr edit --body-file ...` makes a GraphQL mutation that fetches reviewer/team data and requires `read:org` on the token. If the token doesn't have it (some agent tokens only have `repo` + `gist` + `user`), gh prints the scope error but the body update doesn't land. The verify step from section 6 (`gh pr view <n> --json body --jq .body`) catches this — and the fallback is the REST API, which works on `repo` alone:

  ```bash
  jq -Rs '{body: .}' < "$PR_TMP/body.md" > "$PR_TMP/patch.json"
  gh api -X PATCH "repos/<owner>/<repo>/pulls/<n>" --input "$PR_TMP/patch.json" -q .body | head -5
  ```

## Delegating PR-body drafting to a sub-agent

If you hand PR-body drafting to a sub-agent (e.g. for a non-Claude voice, a second-opinion rewrite, or a long-form summary), the sub-agent will faithfully copy whatever marker style you give it — and will hallucinate plausible-looking markers if you give it section names without the literal template.

Failure mode observed in practice: a sub-agent given only a list of section names (not the literal template) produced plausible-looking label markers — `environment:…`, `validation:ci`, `rollback:revert`, `mitigation:none` — that didn't exist in the repo's labeling workflow. The PR rendered fine to humans, but every label keyed off those markers silently failed to apply.

Rules when delegating:

1. **Paste the actual template into the prompt.** Run `cat .github/pull_request_template.md` and include the output verbatim, not a paraphrase or section list.
2. **Treat the template as the marker source of truth.** Tell the sub-agent that any marker it uses must appear verbatim in the template you pasted.
3. **Tell the sub-agent to print only the body** (no preamble, no fenced code block around the body, no commentary). That way you can pipe directly to a body file.
4. **Re-check the markers before posting.** Compare markers in the generated body against markers in the current template, as shown in `references/template-formats.md`. If the sub-agent invented one, fix it or re-prompt before patching the PR.

## Boundaries

This skill stops at "PR is open and reported back to the user." Driving the PR through review, addressing comments, re-requesting Copilot review, and waiting for CI all live in the `manage-pr` skill.
