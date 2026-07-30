---
description: Use when the user wants to decommission a feature flag whose rollout is complete — phrases like "remove a feature flag", "clean up a fully rolled-out FF", "delete this flag", "find a 100% flag and remove it".
metadata:
    github-path: skills/remove-feature-flag
    github-ref: refs/heads/main
    github-repo: https://github.com/github/agent-config
    github-tree-sha: 8c46c33e994fdc2facbf4568f9e999b96848b270
name: remove-feature-flag
---
# Remove Feature Flag — decommission a fully rolled-out FF cleanly

Use this skill when the user wants to retire a feature flag that's at 100% rollout. The mechanics (delete the constant, delete the field, fix the consumers) are easy. The traps that bite people are around **what the FF gate was hiding** (snapshot fixtures, dead code paths, ordering bugs in dev tooling) and around **proving the rollout** before you start.

## When to Use This Skill

- "Remove the `<flag-name>` feature flag from <repo>."
- "This flag's been at 100% for weeks — clean it up."
- "Find a fully rolled-out flag in this repo and remove it."
- "Delete the FF and the dead code path behind it."

If the flag is **not** fully rolled out yet, stop and tell the user — removing a partially-rolled flag is a different task (and usually not what they want).

This skill ends with a draft PR open and CCR happy. Driving the PR through human review and merge is `manage-pr` territory; to open the PR itself, invoke the `create-pr` skill (worktree + template).

## Workflow

### 1. Identify the flag and prove it's fully rolled out

The user may name the flag, or may ask you to find one. Either way, **never trust the name alone** — verify the rollout before writing code.

**Primary check — the feature-flags MCP server.** Call `get_feature_flag(flag_name)` and read the **Rollout by Stamp** table. This is the authoritative configured state, live from Vexi (the same data DevPortal shows). If you don't know the exact name, find it with `search_feature_flags(query=..., search_type="name")` (or `search_type="service"` to list a service's flags).

A flag is safe to remove only when **every** stamp shows:

- `State` = `shipped` (not `partially-shipped` or `disabled`),
- no restrictive **Custom Gates** — e.g. `preview_features` or a named segment means it's on only for that audience, not everyone,
- no percentage holdout — `Percentage of actors` / `Percentage of calls` is `-` or `100`, never a partial number.

If **any** stamp is not fully shipped — `disabled`, `partially-shipped`, a sub-100% percentage, or a restrictive custom gate — **stop and surface it.** That remainder could be a kill-switch, a region-specific holdout, a preview-only gate, or a rollout someone paused on purpose. Removing the flag would silently force it on everywhere.

`get_feature_flag` also returns the **Browser URL** (DevPortal), **Tracking URL** (issue/PR, when present), and **Last Updated** — note all of them; they feed step 2 and the PR body.

When the user gave you a placeholder/example flag name, it's fine — `search_feature_flags(search_type="service", query="<service>")` and check the `shipped` candidates with `get_feature_flag` in a bounded batch. If none of the first batch is fully rolled out, report that and ask before scanning more.

#### Cross-check the flag's change history (is anyone still tuning it?)

Before removing, confirm the flag **isn't still being actively changed** — a flag the team is still iterating on (recent percentage bumps, actor adds, state toggles) is one to pause on and ask about, not remove.

The **Last Updated** field from `get_feature_flag` is your primary recency signal: if it's very recent, pause and surface it. To see *what* changed, read the **first page** of `get_feature_flag_history(flag_name, stamp)` (newest first) on a rolled-out stamp — recent entries mean it's still being tuned. Don't page to the end.

### 2. Find a tracking issue

Before removing the flag, find an issue or PR that documents why it existed. This goes into the PR body so reviewers don't have to reconstruct the history.

```bash
gh search issues --owner github "<flag-key>" --json number,title,state,repository
gh search prs --owner github "<flag-key>" --json number,title,state,repository
```

Useful queries:
- The flag-key string itself (e.g. `copilot-code-reviews-use-grouping-detector`)
- The constant name (e.g. `UseGroupingDetectorFeatureFlag`)
- The original PR that introduced the flag (often the most useful link — has the original "why")
- Any A/B experiment epic that gated the rollout

If you can't find anything, that's worth saying in the PR body too — reviewers will appreciate the honesty.

### 3. Map the full surface area before you start editing

A feature flag is rarely just a constant. Run a full grep for **every** identifier and string the flag uses, in **every** file type, **in the current repo first**:

```bash
grep -rn "FlagConstName\|flag-key-string\|JSON_FIELD_NAME\|ENV_VAR_NAME" \
  --include="*.go" --include="*.yaml" --include="*.yml" \
  --include="*.sh" --include="Dockerfile*" --include="*.md"
```

Things to look for, beyond the obvious constant + field + resolution call:

- **Settings struct fields** with JSON tags — these may be persisted in datastores (CosmosDB, blob storage). Removing the field is fine for in-repo unmarshaling (unknown fields are ignored), but flag external consumers in the PR body.
- **Workflow / template files** — Go templates with custom delimiters (e.g. `#<< .Field >>` in github/copilot-code-review-agent) reference the field by name. Removing the field without removing the template reference will fail to render.
- **Snapshot test fixtures** — repos that test rendered workflows compare against `.expected.yaml` files. After your change these will drift; update them in the same PR.
- **Telemetry / log emitters** — `t.settings.Field` calls that log to StatsD / Hydro / Splunk. Removing the field without removing the emit causes a compile error; removing the emit changes log shape (usually fine, sometimes an analytics consumer cares).
- **Local dev scripts** — Dockerfiles and helper scripts that read `USE_X` env vars. These are pure dead code paths once the FF is gone.
- **Test mocks / FF default maps** — most repos have a central map of "FF defaults for tests"; the entry there has to go too.
- **Dependent FFs** — a flag may be gated *behind* the one you're removing (`if useGrouping { enableExclusion = ... }`). Once the outer gate is always-true, the inner check becomes a no-op. Just always pass through the dependent value; don't remove the dependent FF unless it's also at 100%.

### 3.5. **Cross-repo search — DO NOT SKIP**

> 🚨 **This step exists because of a real production incident.** The `copilot-code-reviews-use-agentic-autofind` FF was removed from `copilot-code-review-agent` cleanly. Build green, tests passed, CCR happy, PR merged. **It triggered availability-incident-3575** because the Ruby monolith (`github/github`) was still using the same FF as a *hard gate* in `repository.feature_flag_enabled_or_raise?(...)` for `get_integration_job_secrets`. Once Vexi noticed CCRA was no longer polling the flag, traffic patterns shifted, and the monolith started raising on requests it had previously allowed. The single-repo grep showed nothing because the consumer was in a totally different codebase.

A feature flag is **organizationally scoped, not repo scoped**. Other services and the monolith may depend on the same flag key. The single-repo grep from step 3 catches in-repo references; this step catches everything else.

Run a `gh search code` sweep across the entire `github` org for **every identifier** the flag uses:

```bash
# The flag-key string itself (the most common cross-repo reference type)
gh search code "<flag-key-string>" --owner github --limit 50

# The constant name (less common, but used by other Go services)
gh search code "<FlagConstantName>" --owner github --limit 50

# The JSON tag, if persisted (this catches downstream JSON consumers)
gh search code "<json_field_name>" --owner github --limit 50
```

Categorize **every** result — repo by repo, file by file. The categories that matter:

| Category | Where it lives | Action — do this *before* removing the FF in the originating repo |
| --- | --- | --- |
| **Ruby monolith hard gate** (`feature_flag_enabled_or_raise?`, `feature_flag_enabled?`) in `github/github` | `app/`, `lib/`, `config/` | **BLOCKER.** This is what caused the agentic-autofind incident. The monolith is rejecting requests based on the flag. You **must** coordinate removal of the monolith reference first (or simultaneously). Do NOT proceed in isolation. |
| **Other Go service consumer** | `github/sweagentd`, `github/copilot-agent-runtime`, etc. | Coordinate removal in that repo too. Open a parallel PR. |
| **Monolith test fixtures** (`enable_feature_flag(...)`, `disable_feature_flag(...)`) | `test/integration/...` | Remove in the same coordinated PR set. Tests will fail if the FF doesn't exist anymore. |
| **Setup / dev scripts** | `github/github:script/setup-*`, `github/copilot-code-review:docs/dev-setup.md` | Remove the toggle line; otherwise local-dev setup leaves dead `ff e` commands behind that confuse newcomers. |
| **Oncall playbooks** | `github/ops:docs/playbooks/...` | **Mandatory update.** Playbooks that say "decrease the % of reviews via this FF" become incorrect once the FF is gone. Oncalls following stale playbooks during incidents is real harm — update or remove the guidance. |
| **Postmortem / incident docs** | `github/ops:docs/playbooks/.../availability-incident-*.md` | Don't rewrite history — these are historical records. But add a forward-link or note clarifying the FF no longer exists. |
| **Team docs / FF inventory pages** | `github/<team>/docs/feature-flags.md` | Remove the row. Otherwise the FF inventory misleads team members and audit reviewers. |
| **Codeowners / config files** referencing the FF as a tracked entity | `.github/`, `CODEOWNERS`-adjacent | Verify and update. |

#### Required output of this step

Before you make any edits, write down (mentally or in a scratch file):

1. **The originating repo** — where you're doing the surgical removal (e.g. `copilot-code-review-agent`).
2. **The list of cross-repo references**, grouped by category from the table above.
3. **The blocker count** — number of category "Ruby monolith hard gate" or "Other Go service consumer" matches. **If non-zero, you cannot safely remove the FF in the originating repo alone.** Either:
   - Coordinate a PR set across all consumer repos (preferred — see workflow below), OR
   - Confirm with the owning team that the cross-repo reference is being removed in parallel by someone else, with a hard date, and link to that work in your PR body.

#### Coordinated multi-repo removal — the safe pattern

When cross-repo blockers exist, the order of operations is:

1. **Open the consumer-repo PRs first** (e.g. `github/github` removing the `feature_flag_enabled_or_raise?` call). These don't need to wait for the originating repo.
2. **Wait for them to merge and ship** — the FF still exists in Vexi at this point and the originating repo still polls it; you've only removed the *gate* in the consumer. Production behavior doesn't change because the FF was at 100% anyway.
3. **Then open the originating-repo PR** removing the FF declaration, resolution, and gated code path. By this point no-one is reading the FF in any code path, so removal is genuinely safe.
4. **Then** turn off the FF in Vexi (or let the FF cleanup automation do it).

Fast pattern (when consumer references are trivial — e.g. just a docs row): bundle them into a single coordinated effort, but still open one PR per repo so each can ship + revert independently.

#### Don't trust an empty cross-repo search

If `gh search code "<flag-key>" --owner github` returns nothing other than the originating repo, **double-check**:
- Did you also search the constant name? Some repos hardcode the kebab-case string; others import a Go constant.
- Did you search the JSON field name? Persisted records may use that key.
- Are there enterprise-only consumers (`github/github-enterprise`, etc.) that the org-scoped search may miss?
- Is the FF surfaced via API where customers/integrators set it (e.g. exposed as a webhook field)?

When in doubt, check `github/github` explicitly (it's the most common surprise consumer): `gh search code "<flag-key>" --repo github/github`.

### 4. Adversarial review the plan before editing — and the diff after

Run the **`adversarial-review`** skill twice on every non-trivial FF removal:

- **Pre-edit pass** — input the full surface area inventory from step 3 + your proposed change. The agent will surface plan-level errors while changes are still cheap.
- **Post-edit pass** — input the actual `git diff` of your branch. Catches "what you actually shipped diverges from what you said you'd do" — historically the highest-leverage moment.

The `adversarial-review` skill handles the model override (GPT-5.5 high), the prompt template, and the triage framework. **Do not duplicate that logic here.** Just invoke it with the FF-specific context.

When invoking, include these constraints so the agent doesn't waste cycles arguing for changes you've already ruled out:

- "The base FF is being removed, but kill-switch FF X (if any) must remain."
- "JSON schema compatibility for downstream consumers Y and Z is required."
- "Snapshot fixtures in `<paths>` need updating; flag if I missed any."

After the agent returns findings, score them against the **FF-specific high-value catches** below — these are the patterns that have actually bitten on real FF cleanup PRs. If the agent missed one that applies to your diff, prompt it again with the specific question (faster than re-running the full pass).

| Pattern | Symptom | Fix |
| --- | --- | --- |
| Field deleted, but downstream reader (e.g. monitor, datastore) still reads its JSON tag | Persisted reviews lose the key, monitor branches dispatch wrong | Restore the field; populate from the now-unconditional resolver. The base FF can still be deleted. |
| Field kept hardcoded-true with vestigial ExP read (`_ = assignment.GetBool(...)`) | Dead code; misleading test surface; reviewer comments will all push to *restore* the field | Delete the field. If a downstream binary needs the key, hardcode the literal in the *one* place that emits it (e.g. `agent.go` flag map). |
| Defensive `*bool` introduced in observability-only consumer | Adds nil-check noise; legacy persisted rows now classify as Unknown instead of their real value | Keep `bool`. Observability tags can be slightly stale on historical rows. |
| Shortcut helper duplicates `Settings.X` | Two sources of truth | Delete the helper; read `Settings.X` directly. |
| Sub-agent adds 5+ `Maybe()` mocks across test files | Production gate stopped short-circuiting → test surface area exploded | Either restore the short-circuit (extract resolution into a helper), OR refactor the test helper to bypass `NewExecution`/`ResolveSettings` entirely. |
| `if FF { step }` becomes `if true { step }` | Dead conditional | Remove the gate; if the step now runs in code paths it never used to, recheck step 6 (bugs the gate was hiding). |
| PR description describes previous design after a pivot | CCR comments will all push you to undo the pivot | Update the PR body *first*, then resolve threads pointing at the body. |

### 5. Make the edits

Invoke the `create-pr` skill: worktree as a sibling directory, branch named `<user>/remove-<short-flag-name>-ff`. Don't touch the user's primary checkout.

Batch all the independent edits into one response. Order doesn't matter for correctness — `go build` will catch any forgotten reference. Typical edit set:

1. Delete the FF constant.
2. Delete the `Settings` struct field (and its JSON tag).
3. Delete the FF resolution line.
4. Delete the field from any internal `Agent`/config struct that mirrored it.
5. Delete the field from any `GetWorkflowData`/serialization map.
6. Delete the gate from workflow / template files. Decide whether the gated step should now always run or be deleted entirely.
7. Delete the gate from local-dev scripts.
8. Delete the field from telemetry emit maps.
9. Delete the entry from test FF default maps.
10. Delete the field from expected-Settings fixtures in tests.
11. Update any snapshot expected-YAML fixtures.
12. Delete unused test struct fields that referenced the flag (often dead even before your change).

Verify with `go vet ./...`, `go build ./...`, then run the full short test suite (`make test-short` or equivalent). Lint if a local linter is installed (golangci-lint often isn't on dev boxes — say so in the PR if you couldn't run it).

### 6. Look for bugs the FF gate was hiding

This is the single most important step and the easiest to skip.

When a step was gated `if FF { … }`, removing the gate makes the step **always run**, including in code paths where it never used to run before. Common bugs that surface:

- **Ordering bugs.** Two steps that ran in opposite orders in different code paths now both always run, and one path's order is wrong. (In this repo's grouping example: production workflow ran grouping → dedup; local-dev ran dedup → grouping but had grouping gated off, so it never mattered. Removing the gate exposed the inversion.)
- **Input contamination.** A step globs `*.json` from a directory that previously was empty in unflagged paths. Now those paths run and the directory contains stale output from earlier steps.
- **Resource leaks.** A worker, connection, or temp directory that was conditionally created now always is.
- **Telemetry double-counting.** An emit that was gated to one path now fires from both.

Before declaring done, **read every site that consumed the FF value** and ask: *what other state does this code path assume? Was that assumption only true on the FF-on path?* If you can't answer that confidently, run the post-edit adversarial pass again with the specific question.

### 7. Open a draft PR

Invoke the `create-pr` skill for the mechanics. The PR body needs (in addition to the repo template):

- Rollout evidence from the feature-flags MCP: the flag's DevPortal URL (`get_feature_flag` returns it as **Browser URL**), the tracking issue/PR URL (`get_feature_flag` returns it as **Tracking URL**, when present), and a one-line per-stamp summary (e.g. "shipped on all stamps, no custom gates, as of `<Last Updated>`").
- Link to the original introduction PR.
- **Cross-repo inventory** from step 3.5 — every consumer outside this repo, with its disposition (already removed in PR #X / removed in linked PR / out-of-scope and why). If the cross-repo inventory was empty, say so explicitly: "Searched `github` org via `gh search code <flag-key>` and found no other consumers."
- Explicit callout of any **dependent FFs** that are *not* being removed and how they now flow through.
- **Out-of-scope** section listing pre-existing issues you noticed but deliberately didn't fix (e.g. local-dev parity gaps unrelated to the FF).
- A rollback strategy: usually "revert this PR; the rendered workflow regenerates per dispatch so reverting restores the old behavior on next deploy" plus mention any independent kill-switches that remain (e.g. a related FF that can still flip the user-facing piece).
- Dashboards / metrics to monitor on rollout — any product metrics that should be unaffected, since prod was already fully shipped.

Default to `--draft`.

### 8. Run CCR and iterate

Hand off to `manage-pr`'s loop: re-request `copilot-pull-request-reviewer[bot]` (note the `[bot]` suffix), wait for the review, address comments, repeat until CCR approves with 0 comments.

CCR is especially good at catching the bugs from step 6 — take its workflow / dev-tooling comments seriously even when they look like "nits". Frequent productive findings:

- "X is now passed through unconditionally; consider adding a focused test." → add a focused test, even if there's tangential coverage elsewhere.
- "This now globs $directory which contains $unexpectedFile in code path Y." → fix the input filter, don't argue.

## Common Pitfalls

- **Skipping the cross-repo search (step 3.5).** This is what caused availability-incident-3575 — single-repo grep showed nothing while the Ruby monolith had a hard `feature_flag_enabled_or_raise?` gate on the same FF. **Always run `gh search code "<flag-key>" --owner github` before editing.**
- **Trusting the flag name without checking rollout.** Always run `get_feature_flag` first — the user's example name might be gated, partially shipped, or not even exist anymore.
- **Reading `shipped` as "on for everyone".** Check the per-stamp **Custom Gates** column — a `preview_features` or named-segment gate means the flag is only on for that audience, not a full rollout.
- **Forgetting workflow snapshot fixtures.** Snapshot tests will fail loudly; the adversarial pass almost always catches this if you list the files. Don't skip step 4.
- **Removing a *dependent* FF by accident.** When `if outerFF { innerFF check }` becomes always-true on outer, the inner stays a real FF — keep the inner check.
- **Hardcoding `true` somewhere instead of deleting.** If both consumers of a workflow-data field are also being deleted, leaving `"Field": true` is dead state. Delete it.
- **Declaring done without re-running CCR.** The fixes for CCR's first round of comments often introduce new state — re-run until 0 comments on the head SHA.
- **Skipping the bugs-the-gate-was-hiding question.** If you don't ask, "what assumption was only true on the FF-on path?", you'll ship a regression that bit on the path that used to be FF-off.
- **Letting oncall playbooks rot.** A merged removal that leaves stale oncall guidance in `github/ops` causes harm during the next incident, when the oncall reaches for a FF that no longer exists. Always update the playbook in the same coordinated effort.

## Boundaries

**Will:**
- Verify rollout via the feature-flags MCP (`get_feature_flag`, per-stamp state) before editing.
- Cross-check the flag's change history via the feature-flags MCP (`get_feature_flag_history`).
- Search for tracking issues and the introduction PR.
- Map the full FF surface area across Go, YAML, shell, and tests **in the originating repo**.
- **Search across the entire `github` org for cross-repo references** and surface every consumer.
- **Block in-repo removal when cross-repo blockers exist** (Ruby monolith hard gates, other Go service consumers) and coordinate the multi-repo PR set first.
- Make the surgical removal in a worktree on a branch.
- Run vet/build/tests and lint where available.
- Hunt for ordering / contamination / leak bugs that the gate was hiding.
- Update oncall playbooks and team docs in the same effort.
- Open a draft PR with rollout evidence, cross-repo inventory, and a rollback strategy.
- Run CCR and respond to comments until 0-comment approval.

**Will Not:**
- Remove a flag that isn't at 100% across the relevant service tier.
- Skip the rollout check (`get_feature_flag`) because the user named the flag confidently.
- **Skip the cross-repo `gh search code` sweep.**
- **Proceed with in-repo removal when a Ruby monolith hard gate or other-Go-service consumer still references the flag** — coordinate first.
- Remove a dependent FF that's still partially rolled out.
- Force-merge or mark non-draft without explicit user say-so.

## References

- [`references/grep-recipes.md`](references/grep-recipes.md) — grep incantations for mapping the full surface area of a flag.

## Related Skills

- `create-pr` — invoked in step 7 to open the PR (worktree + template conventions).
- `manage-pr` — drives the PR through CCR / human review / CI to merge in step 8.
- `audit-flag-rollout` — read-only sibling skill (same feature-flags MCP) for finding flags that *aren't* fully rolled out yet.
- `remove-stale-feature-flags` — issue-driven batch triage of stale flags tracked in `github/feature-flag-lifecycle`; discovers and classifies flags, then hands a confirmed single flag to this skill for careful removal.
