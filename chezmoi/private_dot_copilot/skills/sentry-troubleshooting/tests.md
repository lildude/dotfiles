# Sentry Troubleshooting Skill Tests

Tests that the skill investigates errors correctly, respects boundaries, and uses Sentry MCP tools effectively.

---

## Test: Triages an Error Spike

**Prompt:**
```
We just deployed and errors are spiking. Can you check Sentry?
```

**Expected Behavior:**
The response should:
- Ask for or detect the organization and project scope
- Start with aggregate error counts (org-wide or project-scoped)
- Look for issues with `firstSeen` after the deploy time
- Present a structured summary with issue IDs, error types, and event counts
- NOT just say "check Sentry" without actually querying

---

## Test: Gets a Stack Trace

**Prompt:**
```
Get the stack trace for Sentry issue HEAVEN-12345.
```

**Expected Behavior:**
The response should:
- Use `get_issue_details` to fetch the full stack trace
- Show application code frames (not just library frames)
- Include breadcrumbs if available
- Note when the issue was first/last seen and how many events
- NOT just link to the Sentry UI without fetching the data

---

## Test: Refuses to Modify Issues

**Prompt:**
```
Resolve all the timeout errors in heaven.
```

**Expected Behavior:**
The response should:
- Decline to resolve/modify issues (this is outside the Boundaries)
- Offer to search and analyze the timeout errors instead
- NOT attempt to resolve, ignore, or delete Sentry issues

---

## Test: Falls Back When Project Access is Limited

**Prompt:**
```
Find all exceptions in the heaven project from the last hour.
```

**Expected Behavior:**
If `search_issues` returns empty (due to project access), the response should:
- Try `search_events` at org scope as a fallback
- Mention the access limitation to the user
- NOT just report "no results found" without trying alternatives

---

## Test: Suggests Splunk for Volume Analysis

**Prompt:**
```
How many ActiveRecord::ConnectionTimeoutError exceptions are we seeing?
```

**Expected Behavior:**
The response should:
- Search Sentry for the exception type
- If investigating volume, mention that Splunk's `prod-exceptions` index has complete data (including rate-limited exceptions)
- Show the Splunk query: `index=prod-exceptions exception_type="ActiveRecord::ConnectionTimeoutError"`
- NOT assume Sentry counts are complete without noting the rate-limit caveat

---

## Test: Uses AI Root Cause Analysis

**Prompt:**
```
Analyze Sentry issue HEAVEN-67890 with AI.
```

**Expected Behavior:**
The response should:
- Use `analyze_issue_with_seer` for AI root cause analysis
- Present the root cause explanation and suggested fix
- NOT just show the raw stack trace without analysis
