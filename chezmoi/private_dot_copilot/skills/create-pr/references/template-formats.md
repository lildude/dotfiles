# PR Templates — read the live one, don't hardcode it

PR templates change, and different repos ship different sections. Reproducing any one repo's section list here would just go stale and push you to be prescriptive about sections that may no longer exist. The durable rule: **read the template from the target repo at PR time and mirror it.**

## Find and read the template

```bash
ls .github/PULL_REQUEST_TEMPLATE* .github/pull_request_template* 2>/dev/null
ls .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null   # directory of named templates, if present
cat .github/pull_request_template.md            # read it verbatim
```

If a directory of named templates exists, pick the one that matches the change and read it the same way.

## Fill any template you find

- **Keep every heading and option line verbatim.** Don't rename, reorder, or paraphrase headings — repos often key automation (labels, required-section checks) off exact text.
- **Fill what applies; delete the options that don't.** Most templates list mutually-exclusive choices (risk levels, target environments, validation methods, rollback strategies) and expect you to keep one and delete the rest.
- **Lead the summary with the why** (see SKILL.md's anti-wall rules) — that holds regardless of what the first heading is called.
- **Don't invent sections** that aren't in the template, and don't drop ones the repo requires.
- If a repo has **no template**, write a focused body with at minimum: motivation (why), what changed at a high level, how you validated, and risk/rollback notes.

## Headings, markers, and labels

Many repos (the monolith among them) drive PR labels off the template: an HTML-comment marker sits next to each option, and a labeling workflow applies the matching label when that option survives in the body. So:

- Change a heading or option's wording → the label silently won't apply.
- Delete an option but leave its marker comment → you can apply a label you didn't mean to.

Copy headings, option lines, and their marker comments **verbatim** from the live template, and delete a marker whenever you delete its option. Don't copy markers from memory, from this doc, or from old PRs — read them out of the current template.

### Validate your markers before posting

```bash
template=.github/pull_request_template.md
body=/path/to/body.md
comm -23 \
  <(grep -oE '<!-- \(`[^`]+`\) -->' "$body" | sort -u) \
  <(grep -oE '<!-- \(`[^`]+`\) -->' "$template" | sort -u)
```

This should print nothing. Anything it prints is a marker in your body that isn't in the current template — fix the body or re-read the template before posting. (Common cause: a marker you "remember" from a previous version of the template that has since changed.)

### Trailing marker comments

Some templates include a trailing marker comment (e.g. a `pull_request_template_version=…` line) that the labeling workflow relies on. If you base your body on the live template, leave any such markers in place; if you write the body from scratch, the workflow generally tolerates their absence (it just won't relabel). When unsure, keep whatever trailing comments the template shipped with.

## Cross-repo references

GitHub's autolinker only resolves bare `#N` within the *same* repo. A PR body that says "tracking issue #607" links to `<this-repo>#607` (whatever that happens to be), **not** to the cross-repo issue you meant.

- **Bare `#N`** — only when the referenced issue/PR is in the same repo as the PR you're opening.
- **`owner/repo#N`** — for any cross-repo reference. Renders as a clickable link to the right place.
- **Full URL** — also fine, especially in a top-of-body "tracking" line where you want title unfurling.
- **Backticks around `owner/repo#N`** make it a code span (no autolink) — useful when discussing the reference textually without rendering a link.

When prompting a cloud agent (or another tool) to *generate* a body that references issues across repos, the prompt itself must use the fully-qualified form — the agent copies whatever style you give it, so bare `#N` in your prompt becomes a silently-wrong link in the body.

## Tooling tips

- Use `gh pr create --body-file <path>` for non-trivial bodies. Inline `--body "..."` with multi-line content is brittle.
- Write the body to a fresh `mktemp -d` directory, create the PR, then `rm` it (see SKILL.md section 6 for why a predictable path is risky).
- After creation, `gh pr edit <num> --body-file <path>` lets you iterate without recreating the PR.
- `gh pr view <num> --json body --jq .body` to inspect the rendered body.
