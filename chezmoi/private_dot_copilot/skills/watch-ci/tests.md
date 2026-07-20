# Watch CI Skill Tests

Tests that the skill monitors CI correctly and follows background-first, notification-driven patterns.

---

## Test: Defaults to Background Monitoring

**Prompt:**
```
Can you watch CI for my PR?
```

**Expected Behavior:**
The response should suggest running the monitoring as a background task.
It should NOT block the terminal with foreground polling unless the user explicitly asked for it.
It should mention notifying the user when checks complete or fail.

---

## Test: Identifies Current PR Automatically

**Prompt:**
```
Watch CI and let me know when it's green.
```

**Expected Behavior:**
The response should attempt to detect the current branch's PR (e.g., via `gh pr view`) rather than asking the user to provide a PR number.
If no PR is found for the current branch, asking the user for a PR number is acceptable.
It should NOT require a PR number as a mandatory first step when the user doesn't provide one.

---

## Test: Reports Failures with Next Steps

**Prompt:**
```
CI failed on PR #42. What happened?
```

**Expected Behavior:**
The response should:
- Show which checks failed (not just "CI failed")
- Provide or suggest links to failed logs (e.g., `gh run view --log-failed`)
- Suggest actionable next steps (view logs, re-run, analyze failure)
- NOT just say "a check failed" without helping the user investigate
