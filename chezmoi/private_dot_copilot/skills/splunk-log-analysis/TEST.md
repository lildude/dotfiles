# Splunk Log Analysis Skill Tests

Tests that the skill builds correct SPL queries, uses GitHub-specific indexes/fields, and respects boundaries.

---

## Test: Builds a Basic Error Query

**Prompt:**
```
Search Splunk for errors in the last hour.
```

**Expected Behavior:**
The response should:
- Ask which index or service to search, or use `splunk-list_indexes` (`list_indexes` in some clients) to discover
- Build a valid SPL query with `earliest=-1h latest=now`
- Use `splunk-search_splunk` (`search_splunk` in some clients) to execute it
- Present results in a structured format with counts
- NOT hallucinate index names without checking

---

## Test: Uses Correct GitHub Indexes

**Prompt:**
```
Find timeout errors for the IssuesController.
```

**Expected Behavior:**
The response should:
- Use `index=rails` for web request logs (not a generic index)
- Filter by `controller=IssuesController` and `timeout=true`
- NOT use `index=prod-resque` (that's for background jobs)

---

## Test: Uses prod-exceptions Correctly

**Prompt:**
```
Find all ActiveRecord::RecordNotUnique exceptions for the security_alerts service.
```

**Expected Behavior:**
The response should:
- Use `index=prod-exceptions` (not `index=rails`)
- Use `rails.controller.name` not `controller` (prod-exceptions uses different field names)
- Use `exception_type="ActiveRecord::RecordNotUnique"` and `catalog_service=github/security_alerts`
- NOT confuse field names between the `rails` and `prod-exceptions` indexes

---

## Test: Refuses to Modify Splunk

**Prompt:**
```
Create a new Splunk index for my team's logs.
```

**Expected Behavior:**
The response should:
- Decline to create indexes (outside Boundaries)
- Point the user to the entitlements process or #splunk Slack channel
- NOT attempt to create or modify Splunk configuration

---

## Test: Generates Shareable URLs

**Prompt:**
```
Build a Splunk query for PullRequestsController timeouts and give me a link I can share.
```

**Expected Behavior:**
The response should:
- Build the SPL query
- Generate a clickable Splunk URL using `splunk.githubapp.com` (the web UI, not the API endpoint)
- Present as a markdown link
- NOT use `splunkazure-api-azure-eastus.octoca.ts.net` in shareable links (that's the API)

---

## Test: Correlates Across Indexes

**Prompt:**
```
I have request ID A1C0:764A:82C13F:878361:62F2C36F — find everything about this request.
```

**Expected Behavior:**
The response should:
- Query `index=rails request_id=...` for the web request
- Query `index=glb request_id=...` for GLB/load balancer data
- Query `index=prod-exceptions gh.request_id=...` for any exceptions
- Present a correlated timeline of events
- NOT search only one index

---

## Test: Handles Empty Results Gracefully

**Prompt:**
```
Search for errors in the prod-resque index for MyNonExistentJob.
```

**Expected Behavior:**
The response should:
- Execute the query and report zero results
- Suggest checking the job name spelling
- Suggest broadening the search or time window
- NOT just say "no results" without troubleshooting guidance
