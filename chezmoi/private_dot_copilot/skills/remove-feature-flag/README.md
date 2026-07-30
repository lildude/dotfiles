# remove-feature-flag

Skill for decommissioning a feature flag whose rollout is complete.

The two failure modes this skill exists to prevent:

1. **Removing a flag that isn't actually fully rolled out** — always verify the per-stamp rollout with the feature-flags MCP server (`get_feature_flag`); never trust the flag name or the user's intuition.
2. **Shipping a regression because the FF gate was hiding a bug** — when a step that was previously gated now always runs, it can expose ordering bugs, input contamination, or assumptions that only held on the FF-on path. CCR is especially good at catching these; take its workflow / dev-tooling comments seriously.

The single most important step is the **adversarial review pass** (step 4 in `SKILL.md`). It runs the rubber-duck agent on `gpt-5.5` (premium model, more willing to disagree) twice — once on the plan, once on the diff — with explicit license to find vestigial fields, defensive plumbing, duplicated state, and design pivots that the PR description doesn't reflect. Skipping it is what produced the long iteration cycles that led to writing this skill.

See `SKILL.md` for the full workflow, and `references/grep-recipes.md` for mapping the FF surface area before editing.

## Installation

```bash
gh skill install github/agent-config remove-feature-flag --scope user
```
