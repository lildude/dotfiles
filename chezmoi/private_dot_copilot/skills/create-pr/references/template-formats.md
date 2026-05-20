# PR Template Formats

## github/github (the monolith)

The template lives at `.github/pull_request_template.md`. It's structured with specific section headings that drive PR labels via `.github/workflows/label_pr_from_template.yml`. Keep heading text exact.

### Structure

```markdown
<short summary paragraph — no heading, sets context, links related issues/PRs as a Markdown list so titles unfurl>

### What approach did you choose and why?

<Describe the change and your thought process. Optional sub-bullets:>
**Tradeoffs:** ...
**Risk:** ...
**Alternatives:** ...
**Attention:** ...
**Observability:** ...
**Accessibility:** ...

### Which feature flags are involved in this change?

<List feature flags with devportal links, or "None" with one-line justification.>

### Which environments does this change target?

<Bulleted list. Delete entries that don't apply. Schema migrations to dotcom must also include proxima.>

- Production: dotcom
- Production: proxima
- Production: GHES
- Non-production: dev/test only
- Non-production: docs

### Risk assessment

<Pick exactly one and justify. Delete the other.>

- **Low risk:** ...
- **High risk:** ...

### How did/will you validate this change?

<Pick one or more. Delete what doesn't apply.>

- **Review-lab deploy** — ...
- **Local server** — ...
- **Tests** — ...
- **Other** — ...
- **None** — ...

### Are there related full stack changes?

- **No**
<or>
- **Yes**
  - **Link any related PRs or issues in `github/github-ui`:** ...
  - **What is the rollout plan to maintain backwards compatibility...?** ...

### If something goes wrong, what are the mitigation and rollback strategies?

<Pick one or more. Delete what doesn't apply.>

- **Other** — ...
- **Experiment** — ...
- **Solo Deploy** — ...
- **Feature Flag** — ...
- **Rollback** — ...
```

### Field-by-field tips

- **Summary paragraph (no heading):** Lead with the *why*, then the *what*. If the change came out of an investigation, link the smoking-gun evidence (Datadog dashboard, Kusto query, Sentry issue) so reviewers can verify the motivation themselves.
- **Approach:** Sub-bullets are optional but using `**Tradeoffs:**`, `**Alternatives:**`, and `**Attention:**` makes the PR much easier to review. Always state what the PR is *not* doing if there's a risk a reviewer will scope-creep it.
- **Feature flags:** If "None", say so explicitly. Don't omit the section.
- **Environments:** Most code changes target dotcom + proxima + GHES. Test/docs/internal-tooling-only changes target only the relevant non-production line.
- **Risk assessment:** Default to "Low risk" only when the change is observability-only, fully behind a feature flag, or test/docs-only. Otherwise prefer "High risk" and lay out mitigations.
- **Validation:** "Tests" alone is fine for pure observability/refactor changes. For behavior changes, also note Review-lab or Local server.
- **Full stack:** Default "No" for pure backend Ruby. If you touched ERB/JS/CSS or any user-facing JSON the dashboard reads, it's "Yes".
- **Mitigation:** "Rollback" is the safest default for changes that don't have a feature flag. Solo deploys are reserved for genuinely scary changes — don't pick this unless the user asked.

### Headings vs labels

The HTML comments next to each option in the template (e.g. `<!-- (\`risk:low\`) -->`) are how `.github/workflows/label_pr_from_template.yml` decides which labels to apply. If you change the heading text or option wording, labels will not apply. **Use the template wording verbatim.**

### Comment markers

The template includes a `pull_request_template_version=2` marker comment at the bottom. The labeling workflow needs this. If you base your body on the template, leave the marker in place; if you write the body from scratch, you can omit it (the workflow tolerates absence, just doesn't relabel).

## github/github-ui

Has its own template at `.github/pull_request_template.md`. Read it the same way. Slightly different sections — typically focused on UI changes, accessibility, and Storybook screenshots.

## Other repos

Always check `.github/PULL_REQUEST_TEMPLATE*` (singular) and `.github/PULL_REQUEST_TEMPLATE/` (directory of named templates). If neither exists, write a focused body with at minimum: motivation, what changed, validation, and risk/rollback notes.

## Cross-repo references

GitHub's autolinker only resolves bare `#N` within the *same* repo. A `github/github` PR body that says "tracking issue #607" links to `github/github#607` (whatever that happens to be — possibly a closed 2009 issue), **not** to the cross-repo tracking issue you meant.

Rules:

- **Bare `#N`** — only when the referenced issue/PR is in the same repo as the PR you're opening.
- **`owner/repo#N`** — for any cross-repo reference. Renders as a clickable link to the right place.
- **Full URL** — also fine, especially in a top-of-body "tracking" section where you want title unfurling.
- **Backticks around `owner/repo#N`** make it a code span (no autolink) — useful when discussing the reference textually but not wanting GitHub to render it as a link.

When prompting a cloud agent (or another tool) to *generate* a PR body that references issues across repos, the prompt itself must use the fully-qualified form. The agent will copy whatever style you give it — bare `#N` in your prompt becomes bare `#N` in the body, with a silently-wrong link.

## Tooling tips

- Use `gh pr create --body-file <path>` for non-trivial bodies. Inline `--body "..."` with multi-line content is brittle.
- For repeat use in the same session, write the body to `/tmp/pr-body-<branch>.md`, create the PR, then `rm` the file.
- After creation, `gh pr edit <num> --body-file <path>` lets you iterate without recreating the PR.
- `gh pr view <num> --json body --jq .body` to inspect the rendered body.
