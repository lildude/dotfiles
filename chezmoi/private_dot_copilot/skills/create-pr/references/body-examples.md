# PR Body Examples — Why / Tests / Coordination

The conventions in SKILL.md's "Section-by-section conventions" are easier to apply with concrete examples. Below is a real PR body (lightly redacted) that survived review unchanged, paired with the earlier drafts that the user rewrote — and **why** each rewrite happened.

## The pattern that works

```markdown
## What

Wire the review-effort tiers to distinct models when agentic autofind is on
and the payload sets `ReviewEffortLevel` explicitly:

- `low` (Light) → `models.Gpt52Medium` *(same as legacy)*
- `medium` (Standard) → `models.ClaudeOpus47Medium` *(was `ClaudeOpus46High`)*
- `high` (Deep) → `models.Gpt55Medium` *(was `ClaudeOpus46High`)*

Unset payloads fall through to today's default-model resolution. Wire enum
values (`low`/`medium`/`high`) unchanged.

## Why

Today Medium and High both resolve to `ClaudeOpus46High` — the dropdown's
depth dimension is cosmetic. This wires each tier to a model that actually
corresponds to its name: Light stays fast/cheap, Standard gets a balanced
model, Deep gets the most capable.

## Coordination

- [github/github-ui#21468](...) — UI relabels Low/Medium/High → Light/Standard/Deep, enables Deep.
- [github/github#433541](...) — Rails allows `high` end-to-end; flips never-touched settings default from `low` to `medium`.

## Gating

- **No CCRA-side FF.** Exposure is gated upstream by the staff-only Rails FF `copilot-code-reviews-review-effort-level`.
- `low` is unchanged; `medium` is a peer-tier swap (Opus 4.6 High → Opus 4.7 Medium, ≈ equivalent quality); `high` only reaches CCRA via the same Rails-side staff dropdown.

## Tests

Covers the new tier mapping, unset → default fall-through (no coercion), and
precedence (ExP > effort > `UseGpt52MediumByDefault` FF > default).

## Rollback

- Normal: disable Rails FF `copilot-code-reviews-review-effort-level` → dropdown stops emitting explicit values → CCRA falls through to default.
- Hard: revert this PR.
```

Notice what this body does **not** have: no per-file walkthroughs, no test-case enumeration, no "non-goals" hedging, no "this PR is part of a 3-PR set …" framing in the Why.

## What got rewritten (and why)

### ❌ Why = "paired with X"

**Earlier draft:**

> ## Why
> This is the agent-side half of the Light/Standard/Deep effort rename.
> Paired with github/github-ui#21468 (UI relabel) and github/github#433541
> (Rails enum + default). Together they ship the new tier names.

**Problem:** That's coordination, not motivation. The reviewer still doesn't know *why this change exists* — what user problem it solves, what's broken today, what's better tomorrow. "Paired with X" describes the project, not the value.

**Fix:** Move the sibling-PR list to a separate **Coordination** section. Then write a Why that stands on its own:

> Today Medium and High both resolve to `ClaudeOpus46High` — the dropdown's
> depth dimension is cosmetic. This wires each tier to a model that actually
> corresponds to its name.

You can read that Why with zero context about the other PRs and still understand the change.

### ❌ Tests = enumerated subtest list

**Earlier draft:**

> ## Tests
>
> Added these table-driven cases to `TestResolveModelGenerateComments_Precedence`:
>
> - `"low effort returns Gpt52Medium"`
> - `"medium effort returns ClaudeOpus47Medium"`
> - `"high effort returns Gpt55Medium"`
> - `"unset effort falls through to default"`
> - `"unset + UseGpt52MediumByDefault FF returns Gpt52Medium"`
> - `"explicit medium beats UseGpt52MediumByDefault FF"`
> - `"explicit high beats UseGpt52MediumByDefault FF"`
> - `"ExP override beats explicit medium"`
> - `"ExP override beats explicit high"`
>
> All nine pass in codespace.

**Problem:** Reviewers don't read test-name lists. They scan the *coverage area* and decide whether to dig into the file. A nine-bullet list buries that signal in noise.

**Fix:** One sentence summarizing the coverage:

> Covers the new tier mapping, unset → default fall-through (no coercion), and
> precedence (ExP > effort > `UseGpt52MediumByDefault` FF > default).

If reviewers want the subtest names, they open the test file. They always can — that's what the diff is for.

### ❌ What = prose paragraph

**Earlier draft:**

> ## What
>
> When agentic autofind is on and a payload arrives with an explicit
> `ReviewEffortLevel`, the resolver now maps `low` to `Gpt52Medium` (same as
> the legacy default), `medium` to `ClaudeOpus47Medium` (replacing the old
> `ClaudeOpus46High`), and `high` to `Gpt55Medium` (also replacing
> `ClaudeOpus46High`). Payloads without an effort level continue to fall
> through to the existing default-model path; the on-the-wire enum stays
> `low`/`medium`/`high`.

**Problem:** Same information, but you have to read a paragraph to extract the mapping. Bullets are scannable; prose is not.

**Fix:** Bullets. (See the working version above.)

### ❌ Body restates what the diff shows

**Earlier draft** (real example from `github/hydro-schemas#8785`):

> Adds the missing `CopilotCodeReviewAgent` snapshot+snapshot shape so the
> aggregator can decode messages without `unknown field` rejections.
>
> Snapshot+snapshot shape matches existing precedents
> (`CopilotSettingsSaved`, `CopilotForBusinessEnterpriseSettingsChanged`,
> `CopilotForBusinessOrganizationSettingsChanged`). Reuses the canonical
> `copilot_code_review_agent.v0.entities.ReviewEffortLevel` enum.

**Problem:** The second paragraph just narrates what the diff already shows. The reviewer can see the snapshot/snapshot pair next to the precedent files in the same directory, and they can see the enum reference in the import. Calling it out in prose adds zero new information; it just makes the body longer and reads as the author hedging ("look, I checked the precedents, please don't bounce this").

**Fix:** Cut the precedent-and-enum paragraph entirely. The first paragraph (which explains *why*: aggregator decode failures) is the part the diff can't tell the reviewer; keep that. The rest of the body should be the rollout/coordination notes the reader can't reconstruct from the code.

## Quick rules

1. **Why must stand on its own.** Cover the sibling PRs in Coordination.
2. **Tests is a coverage summary, not a test-name list.** 1–2 sentences max.
3. **What is bullets and tables, not paragraphs.** Mapping changes are bullets. Multi-step changes are numbered.
4. **Coordination is its own section.** Always — even if there's only one sibling PR.
5. **Gating is one sentence per flag.** Skip the whole section if there's no gating story.
6. **Rollback is two bullets max.** Normal + hard. Skip if rollback is just "revert."
7. **Don't restate what the diff shows.** Precedent matches, canonical-enum reuse, "follows pattern X" are all visible in the imports and the file layout. The body is for what the code can't tell the reviewer.

When in doubt: would the reviewer be annoyed at having to skim past this section to get to the diff? If yes, cut it.
