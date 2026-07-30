# Tests: remove-feature-flag

Behavioral tests for the `remove-feature-flag` skill. Each test states a prompt
and the behavior the skill should produce.

## Test: Verifies full rollout before writing any code

**Prompt:**

```
Remove the copilot-code-reviews-use-grouping-detector feature flag from github/github.
```

**Expected Behavior:**

The agent recognizes the `remove-feature-flag` skill and, before editing code,
verifies the flag is fully rolled out via the feature-flags MCP server
(`get_feature_flag(flag_name)`), reading the Rollout by Stamp table. It treats the
flag as removable only when every stamp is `shipped` with no restrictive custom
gates and no sub-100% percentage. It does not trust the flag name alone.

## Test: Stops on a partially-rolled flag

**Prompt:**

```
This flag is at 60% in one stamp but go ahead and delete it.
```

**Expected Behavior:**

The agent refuses to remove the flag while any stamp is `disabled`,
`partially-shipped`, at a sub-100% percentage, or behind a restrictive custom
gate. It surfaces the remaining rollout (possible kill-switch, regional holdout,
or preview gate) and stops rather than forcing the flag on everywhere.

## Test: Runs the cross-repo search before editing

**Prompt:**

```
The flag is fully shipped — remove it.
```

**Expected Behavior:**

The agent maps the full surface area and performs the cross-repo search step
(does not skip it), searching the whole `github` org for the flag key and its
constant name. It does not trust an empty cross-repo search result at face value,
and it identifies every consuming repo before editing.

## Test: Runs adversarial review and hands off PR mechanics

**Prompt:**

```
Make the edits and open the PR to remove this fully rolled-out flag.
```

**Expected Behavior:**

The agent invokes the `adversarial-review` skill on the plan and again on the
diff (it does not reimplement that review logic itself). It invokes the
`create-pr` skill to make the edits in a worktree and open a **draft** PR, and
hands the PR through CCR / review via `manage-pr`. It does not touch the user's
primary checkout directly.

## Test: Defers batch triage to remove-stale-feature-flags

**Prompt:**

```
Work through all the stale feature flags tracked for my team.
```

**Expected Behavior:**

The agent recognizes that issue-driven, batch triage of stale flags in
`github/feature-flag-lifecycle` is the `remove-stale-feature-flags` skill's job,
and points to or defers to that skill for discovery and classification, using
`remove-feature-flag` only for the careful removal of a single confirmed flag.
