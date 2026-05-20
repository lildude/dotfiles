# Grep recipes for mapping a feature flag's surface area

Before editing, you need a complete inventory of every place the flag is referenced. Missing a reference at this stage is what causes "I removed the FF but the build broke" or worse, "I removed the FF but a downstream service still tries to read the JSON field."

## The opening sweep

Run **one** broad grep across all relevant file types. Include the constant name, the flag-key string, the JSON tag, and any env var name you suspect:

```bash
grep -rn "FlagConstantName\|flag-key-string\|json_field_name\|ENV_VAR_NAME" \
  --include="*.go" \
  --include="*.yaml" \
  --include="*.yml" \
  --include="*.sh" \
  --include="Dockerfile*" \
  --include="*.md" \
  --include="*.rb" \
  --include="*.ts" \
  --include="*.tsx" \
  --include="*.js"
```

Sort the output by file and read every line. Categorize each hit before editing:

| Category | Action |
| --- | --- |
| Flag constant declaration | Delete |
| Settings/config struct field | Delete |
| FF resolution call (`IsEnabledFor*`) | Delete |
| Internal struct field that mirrors it | Delete |
| Workflow data / serialization map entry | Delete |
| Template/workflow YAML reference (`#<< .Field >>`, `${{ }}`) | Delete the gate; decide if step always runs or is removed entirely |
| Local-dev shell script gate (`if [ "$ENV_VAR" = "true" ]`) | Remove gate, keep the body |
| Telemetry/log emit | Delete the entry |
| Test FF default map | Delete the entry |
| Expected-Settings test fixture | Delete the field |
| Expected-YAML snapshot fixture | Update the rendered output |
| Documentation / runbook | Update or remove |
| Dependent FF check (`if outerFlag { innerFlagResolution }`) | Outer gate becomes no-op; pass inner through unconditionally; **keep inner FF** |

## Find consumers of the JSON field

If the `Settings` struct field has a JSON tag, search for the **JSON name** specifically — there may be external consumers (jq/SQL queries, analytics pipelines) that aren't in the same repo:

```bash
grep -rn "use_grouping_detector\|\"use_grouping_detector\"" --include="*.go" --include="*.rb" --include="*.kql" --include="*.sql"
```

In-repo readers usually unmarshal generically and ignore unknown fields, so removing the field is safe for the in-repo path. Out-of-repo consumers (Kusto/Trino dashboards, Splunk searches, analytics jobs) are the unknown — flag the JSON-tag removal in the PR body so reviewers can sanity-check on their side.

## Find downstream env vars

When the FF is plumbed through a workflow into a Docker container or shell script, the env var name often differs from the FF name:

```bash
# Find the launcher mapping
grep -rn "USE_GROUPING\|workflowData\[\"UseGrouping\"\]" --include="*.go" --include="*.sh" --include="Dockerfile*"

# Find consumers of the env var
grep -rn "\$USE_GROUPING\|\${USE_GROUPING" --include="*.sh" --include="Dockerfile*" --include="*.yaml"
```

Typical chain:

```
FF constant
  → Settings field
    → Agent struct field
      → GetWorkflowData() map entry  (Go side)
        → workflow YAML template var (#<< .Field >>)
          → Actions step `if:` condition
        OR
        → docker launcher reads workflowData[...] and sets env var
          → Dockerfile / shell script reads env var
```

Each link is its own grep target. Skip a link and you'll get a compile error or a step that runs (or doesn't) for the wrong reason.

## Find dependent FFs

A flag can be gated *inside* another flag's `if`. Once you remove the outer gate, the inner check becomes unconditional:

```go
// before
useGrouping = stgs.UseGroupingDetector
if useGrouping {
    enableGroupingExclusion = stgs.EnableGroupingExclusion
}

// after — outer gate gone, inner FF preserved
enableGroupingExclusion = stgs.EnableGroupingExclusion
```

To find these patterns:

```bash
# Find conditional reads of related fields near the FF you're removing
grep -B2 -A5 "FlagConstantName\|stgs.<FieldName>" --include="*.go" -r .
```

Look at every site, not just the obvious one — the gate may have been duplicated.

## Sanity-check at the end

After all your edits, run the same broad grep again. The only references that should remain are:

- The PR body / commit message (if checked in).
- Historical references in changelogs or migration docs (preserve these).

If anything else shows up, you missed an edit:

```bash
grep -rn "FlagConstantName\|flag-key-string\|json_field_name\|ENV_VAR_NAME" \
  --include="*.go" --include="*.yaml" --include="*.yml" \
  --include="*.sh" --include="Dockerfile*"
# Expect: empty (or only changelog-style docs)
```

`go build ./...` will catch most missed code references but won't catch missed YAML / shell / template references — those silently become dead code or, worse, render with literal `<no value>`. The grep is your last line of defense.

## Cross-repo search — DO NOT SKIP

> **Why:** the in-repo grep above only catches references in the current codebase. Feature flags are organizationally scoped — the same flag-key may be used as a hard gate in `github/github` (Ruby monolith), referenced in oncall playbooks in `github/ops`, or consumed by other Go services. Removing the FF in one repo while another consumer still depends on it is what causes incidents (see availability-incident-3575 / `copilot-code-reviews-use-agentic-autofind`).

### The opening cross-repo sweep

```bash
# Search all of github org for the kebab-case flag-key string
gh search code "<flag-key-string>" --owner github --limit 50

# Also search for the Go constant name (some repos hardcode the literal, others import the const)
gh search code "<FlagConstantName>" --owner github --limit 50

# If the flag is reflected in JSON (persisted state, API responses, webhooks):
gh search code "<json_field_name>" --owner github --limit 50
```

### Triage matrix — by file path / repo

Categorize every result. The first three categories are **blockers** for in-repo removal:

| Path pattern | Category | Action |
| --- | --- | --- |
| `github/github:app/api/...feature_flag_enabled_or_raise?` | 🚨 Ruby monolith hard gate | **BLOCKER.** Open a parallel PR in `github/github` to remove the gate, ship that first. |
| `github/github:app/...feature_flag_enabled?` | 🚨 Ruby monolith soft gate | Coordinate removal in `github/github`. May be safe to leave temporarily if logic is identical. |
| `github/<other-go-service>:**/*.go` (e.g. `sweagentd`, `copilot-agent-runtime`) | 🚨 Other Go consumer | **BLOCKER.** Coordinate parallel PR. |
| `github/github:test/...enable_feature_flag` / `disable_feature_flag` | Monolith test fixtures | Remove in same coordinated PR set. |
| `github/<team-repo>:docs/feature-flags.md` | Team FF inventory page | Remove the row. |
| `github/<team-repo>:docs/dev-setup.md` | Local dev setup script | Remove the toggle line (`ff e <key>`). |
| `github/ops:docs/playbooks/.../oncall.md` | 🚨 Oncall playbook | **MANDATORY UPDATE.** Stale FF guidance during incidents = real harm. |
| `github/ops:docs/playbooks/.../availability-incident-*.md` | Postmortem doc | Don't rewrite history. Optionally add a forward-link noting the FF no longer exists. |
| `github/github:script/setup-*` | Setup script | Remove the toggle line. |
| `.github/workflows/*` | CI workflow | Verify and update. |

### Verifying empty cross-repo state

After all coordinated PRs land and you're about to do the originating-repo removal, sanity-check:

```bash
gh search code "<flag-key-string>" --owner github --limit 50 \
  | grep -v "^$REMOVAL_REPO:"
# Expect: empty, OR only docs/postmortem references that you've explicitly chosen to leave
```

If the cross-repo search still finds active code references in other repos, **do not proceed**. The flag is still in use somewhere. Either close the cross-repo PRs first, or update your removal plan to coordinate them.
