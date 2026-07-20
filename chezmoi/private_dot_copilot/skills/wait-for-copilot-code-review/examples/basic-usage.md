# Basic Usage Examples

## Example 1: Watch Current PR

```
User: "Watch for Copilot review on my PR"

Agent: I'll watch for Copilot's code review on PR #456 (feat: add auth middleware).

       🔍 Launching background monitor...
       ⏳ Polling every 30s. I'll check back in ~2 minutes.

       [agent sleeps — zero tokens consumed]

       ...2 minutes later...

Agent: ✅ Copilot finished reviewing PR #456!

       Review state: CHANGES_REQUESTED

       Comments (3):
       1. src/middleware/auth.ts:42
          "Consider using constant-time comparison for token validation
           to prevent timing attacks."

       2. src/middleware/auth.ts:67
          "This error message exposes internal implementation details.
           Use a generic message instead."

       3. src/routes/api.ts:15
          "Missing error handling for the case where the token refresh
           endpoint returns a network timeout."

       Would you like me to address these comments?

User: "Yes, fix them all"

Agent: [reads files, applies fixes, shows diff, commits when approved]
```

## Example 2: Watch Specific PR

```
User: "Monitor Copilot review on PR #789"

Agent: Watching PR #789 in github/my-repo for Copilot review...
       ⏳ I'll check back shortly.

       [background polling — no tokens]

Agent: ✅ Copilot reviewed PR #789!

       Review state: APPROVED

       Copilot approved with no comments. You're good to merge! 🎉
```

## Example 3: Review Times Out

```
User: "Watch for Copilot review"

Agent: Watching PR #321 for Copilot review...

       [polls for up to 1 hour]

Agent: ⏰ Copilot review hasn't appeared after 1 hour for PR #321.

       This could mean:
       • Copilot code review isn't enabled for this repo
       • The PR is too large for automated review
       • There's a service delay

       Would you like me to keep watching, or should we move on?
```

## Example 4: Combined with Watch CI

```
User: "Push this and watch both CI and Copilot review"

Agent: Pushed to branch feat/new-feature.
       PR #555 created.

       Setting up background monitors:
       📋 CI checks: monitoring via gh pr checks --watch
       🔍 Copilot review: monitoring via polling script

       I'll let you know when either completes.

       [both run as background shell scripts]

Agent: ✅ CI passed for PR #555! (all 4 required checks green)
       ⏳ Still waiting for Copilot review...

       [continues polling for review]

Agent: ✅ Copilot finished reviewing PR #555!

       Review state: CHANGES_REQUESTED
       1 comment on src/utils.ts:23 — "Unused import"

       Would you like me to fix it?
```
