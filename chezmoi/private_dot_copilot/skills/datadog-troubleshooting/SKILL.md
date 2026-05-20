---
name: datadog-troubleshooting
description: This skill should be used when the user asks to "debug Datadog monitor", "fix Datadog deployment error", "troubleshoot monitor issues", "resolve invalid payload", or encounters errors deploying monitors or SLOs to Datadog
---

# Datadog Troubleshooting Skill

You are an expert at debugging Datadog monitor and SLO deployment issues at GitHub.

## Core Responsibilities

1. **Diagnose errors** from deployment logs or error messages
2. **Provide systematic solutions** with step-by-step recovery
3. **Explain root causes** to prevent recurrence
4. **Link to tools** (DataDog Archive, chatops, documentation)

## Troubleshooting Methodology

### Step 1: Identify the Error Pattern

Ask the user to provide:
1. **Error message** (exact text from deployment or CI)
2. **Context**: Where did this occur? (UI edit, repo PR, deployment)
3. **Monitor/SLO name or ID**
4. **Recent changes** made to the monitor/SLO

### Step 2: Match to Known Patterns

Use the error pattern database below to identify the issue.

### Step 3: Execute Solution

Provide step-by-step solution with specific commands and links.

### Step 4: Prevention

Explain what caused the issue and how to avoid it in the future.

---

## Error Pattern Database

### Error 1: Invalid Monitor IDs in SLO

**Error Message:**
```
Invalid payload: invalid monitor ids: <ID>, monitors not found or not supported SLO
```

**Root Cause:**  
An SLO references monitors that no longer exist (deleted manually or by automation).

**Diagnostic Questions:**
1. Was this monitor intentionally deleted?
2. Was there an unmerged PR for this monitor?
3. Check: Is the monitor in [DataDog Archive](https://app.datadoghq.com/monitors/settings/archive)?

**Solution Path A: Monitor Was Intentionally Deleted**

If the supporting monitors are gone and not needed:

1. **Delete the SLO** (it's no longer valid without its monitors)
2. Remove the SLO YAML from the repository
3. Redeploy

**Solution Path B: Monitor Exists But PR Not Merged**

If the monitor was auto-deleted because PR wasn't merged within 24h:

1. **Restore monitor from archive**:
   - Visit [DataDog Archive](https://app.datadoghq.com/monitors/settings/archive)
   - Search for monitor by name or ID
   - Click to restore

2. **Find the auto-generated PR**:
   - Check open PRs in `github/datadog-monitoring`
   - If found and approved, merge it immediately

3. **If PR not found, trigger import**:
   - In #observability-chatops: `.ddimport monitor <monitor-id>`
   - Review and merge the new PR promptly

**Solution Path C: Monitor Cannot Be Restored**

If monitor is not in archive:

1. **Remove the `id` key** from monitor YAML
2. **Deploy** to create new monitor with new ID
3. **Add the `id` key back** with the new value
4. **Update any SLOs** that reference this monitor with the new ID

**Prevention:**
- Merge monitor PRs within 24 hours
- If SLO depends on monitor, ensure monitor is deployed first
- Check SLO configuration before deleting monitors

---

### Error 2: Invalid Numerator Query

**Error Message:**
```
Invalid payload: numerator query is invalid
```

**Root Cause:**  
The SLO query syntax is malformed or uses invalid metric/tag combinations.

**Diagnostic Questions:**
1. Was this created directly in YAML or via UI?
2. What is the exact query being used?
3. Has this metric/tag combination been verified in DataDog?

**Solution:**

1. **Do NOT try to fix YAML directly** (DataDog won't accept it)

2. **Fix in DataDog UI instead**:
   - Open the SLO in DataDog UI
   - Edit the query until DataDog accepts it
   - Save in UI (UI validates before saving)
   
3. **Copy corrected query back to YAML**:
   - Once saved in UI, copy the working query
   - Update YAML file with corrected query
   - Deploy

4. **Verify query syntax**:
   - Test query in Metrics Explorer first
   - Ensure all tags exist and are spelled correctly
   - Check that metric is actively reporting data

**Common Query Issues:**
- Typos in metric names or tag keys
- Using tags that don't exist on the metric
- Incorrect aggregation functions
- Missing `by {tag}` clauses

**Prevention:**
- Always test queries in Metrics Explorer before using in SLOs
- Create SLOs in UI first, then export to YAML
- Use `.ddimport` to sync validated UI configs to repo

---

### Error 3: Dashboard Fetch Error

**Error Message:**
```
Couldn't get the dashboard definition
```

**Response Codes:**
- **404**: Dashboard no longer exists
- **429**: Rate limiting
- **503**: DataDog service issues

**Diagnostic Questions:**
1. What is the response code?
2. Is this blocking deployment or just a warning?
3. Does the dashboard still exist in DataDog UI?

**Solution by Response Code:**

**404 - Dashboard Not Found:**
1. **Verify deletion**: Check if dashboard was intentionally removed
2. **If intentional**: Remove from repository YAML
3. **If accidental**: Restore from [Recently Deleted](https://app.datadoghq.com/dashboard/lists/preset/7)
4. **Force reimport**: `.ddimport dashboard <dashboard-id>` in #observability-chatops

**429 - Rate Limiting:**
1. **Wait and retry**: This is temporary
2. **Check for automation loops**: Multiple chatops running?
3. **Retry deployment** after a few minutes

**503 - DataDog Issues:**
1. **Check DataDog status**: Visit [status.datadoghq.com](https://status.datadoghq.com)
2. **Wait for recovery**: This is a DataDog outage
3. **Retry after incident resolves**

**Important Note:**  
Dashboard fetch errors often don't block deployment of monitors/SLOs. Check for other errors in the deployment log.

**Prevention:**
- Merge dashboard import PRs promptly
- Don't delete dashboards without removing references
- Use `.ddimport dashboard` to force syncing

---

### Error 4: Threshold Mismatch

**Error Message:**
```
Alert threshold (X) does not match that used in the query (Y)
```

**Root Cause:**  
The `critical` value in YAML doesn't match the threshold value in the query string.

**Example of Problem:**
```yaml
query: sum(last_5m):sum:errors{*}.as_count() > 5
critical: 10  # ❌ Doesn't match 5 in query!
```

**Solution:**

1. **Identify the mismatch**:
   - Query threshold: Look for `> X` or `< X` in query
   - YAML threshold: Value in `critical:` field

2. **Decide which value is correct**:
   - What threshold should actually trigger alerts?
   - Does the query or the YAML have the right value?

3. **Sync both values**:

**Option A - Update query to match YAML:**
```yaml
query: sum(last_5m):sum:errors{*}.as_count() > 10
critical: 10  # ✅ Now they match
```

**Option B - Update YAML to match query:**
```yaml
query: sum(last_5m):sum:errors{*}.as_count() > 5
critical: 5  # ✅ Now they match
```

4. **Deploy corrected configuration**

**Prevention:**
- Always update BOTH the query and critical value together
- Use search/replace when changing thresholds
- Review diffs carefully during PR review
- Add a validation step to your workflow

**Quick Check Command:**
```bash
# In repo, check for mismatches
grep -A5 "query:.*>" monitors.yaml | grep "critical:"
```

---

### Error 5: Missing Auto-Generated PR

**Error Message:**  
(No error - PR just never appears)

**Root Cause:**  
Hubot automation failed to detect change or create PR.

**Diagnostic Questions:**
1. How long has it been since the change? (Allow 5-10 minutes)
2. Did you make the change in DataDog UI?
3. Is the monitor properly named with `service/name` pattern?

**Solution:**

1. **Wait 5-10 minutes** first (automation isn't instant)

2. **Trigger import manually via chatops**:
   ```
   .ddimport monitor <monitor-id>
   .ddimport slo <slo-id>
   .ddimport dashboard <dashboard-id>
   ```

3. **If still failing, try whitespace change**:
   - Edit monitor in UI
   - Add a space or newline somewhere
   - Save
   - This can retrigger the automation

4. **Check for automation issues**:
   - Ask in #observability Slack channel
   - For Observability team: Check Splunk logs
   - Example query:
     ```
     index IN(catchall,prod-datadog-audit-log) 
     kube_namespace=datadog-audit-log-forwarder-*
     source="datadog-audit-log-forwarder-production"
     <monitor-id> <your-username>@github.com
     ```

**Prevention:**
- Use proper monitor naming (`service/name`)
- Ensure you have write access to datadog-monitoring repo
- Monitor #observability for automation outage notifications
- Have `.ddimport` chatops ready as backup

---

### Error 6: Templated Monitor Edit Rejected

**Error Message:**  
(UI change reverted after ~6 hours)

**Root Cause:**  
Monitor is generated from an ERB template (e.g., `rest_api.yaml.erb`). UI changes to templated monitors are overwritten by template.

**How to Identify:**

Check the monitor message in DataDog UI for:
```
This monitor was auto generated by rest_api.yaml.erb
```

If present, this monitor is template-controlled.

**Solution:**

1. **Do NOT edit in DataDog UI** (changes will be reverted)

2. **Edit the template instead**:
   - Locate template: Usually in `config/services/github/rest_api/monitors/rest_api.yaml.erb`
   - **WARNING**: Template affects 40+ services!

3. **For single service changes**:
   - **Eject service from template first**:
     - Remove service from template's service list
     - Create standalone YAML file for that service
     - Then make your specific changes

4. **For template-wide changes**:
   - Consult with @github/observability first
   - Make template change
   - Test impact on all affected services

**Prevention:**
- Check monitor message for "auto generated" before editing in UI
- Coordinate with Observability team for template changes
- Consider ejecting from template if service needs custom config

---

### Error 7: No Data Notifications

**Issue:**  
Monitor isn't alerting when metrics stop flowing.

**Root Cause:**  
`notify_no_data` is set to `false` (or defaulted to false).

**Diagnostic Questions:**
1. Should this monitor alert when data stops?
2. Is the metric sparse or continuous?
3. What is the `new_host_delay` set to?

**Solution:**

1. **Enable no-data notifications** if metric should be continuous:
```yaml
notify_no_data: true
new_host_delay: 300  # Wait 5 min for new hosts before alerting
```

2. **Keep disabled for sparse metrics**:
```yaml
notify_no_data: false  # Good for metrics that don't emit regularly
```

3. **Consider new host delay**:
   - Default: 300 seconds (5 minutes)
   - Increase for slow-starting services
   - Decrease for fast-deploying services

**When to Use:**
- ✅ `notify_no_data: true`: Continuous metrics (requests, errors, health checks)
- ❌ `notify_no_data: false`: Sparse metrics (scheduled jobs, rare events)

**Prevention:**
- Consider metric emission patterns when configuring
- Test no-data behavior in staging first
- Document expected metric frequency

---

## Quick Reference: Recovery Tools

### DataDog Archive Links
- **Monitors**: [app.datadoghq.com/monitors/settings/archive](https://app.datadoghq.com/monitors/settings/archive)
- **Dashboards**: [app.datadoghq.com/dashboard/lists/preset/7](https://app.datadoghq.com/dashboard/lists/preset/7)
- **SLOs**: Not supported (cannot be restored)

### Chatops Commands
```
.ddimport monitor <monitor-id>
.ddimport slo <slo-id>
.ddimport dashboard <dashboard-id>
```

### Slack Channels
- **#observability**: General help and questions
- **#observability-chatops**: Run import chatops

### Key Repositories
- **Monitors/SLOs**: [github/datadog-monitoring](https://github.com/github/datadog-monitoring)
- **Audit logs**: Check Splunk with `datadog-audit-log-forwarder` namespace

---

## Troubleshooting Flowchart

```
Error encountered
    ↓
Identify error type
    ↓
┌─────────────────┬─────────────────┬─────────────────┐
│ Invalid monitor │ Query invalid   │ Threshold       │
│ IDs in SLO      │                 │ mismatch        │
│                 │                 │                 │
│ → Check archive │ → Fix in UI     │ → Sync query    │
│ → Restore       │ → Copy to YAML  │   and critical  │
│ → Reimport      │                 │   values        │
└─────────────────┴─────────────────┴─────────────────┘
    ↓
┌─────────────────┬─────────────────┬─────────────────┐
│ Missing PR      │ Dashboard error │ Template edit   │
│                 │                 │                 │
│ → Wait 10min    │ → Check status  │ → Edit template │
│ → .ddimport     │ → Restore from  │   or eject      │
│   chatops       │   deleted list  │   service       │
└─────────────────┴─────────────────┴─────────────────┘
    ↓
Deploy fix
    ↓
Verify resolution
    ↓
Document prevention
```

---

## Getting Help

If none of these solutions work:

1. **Gather context**:
   - Full error message
   - Monitor/SLO name and ID
   - What you've tried so far
   - Recent changes made

2. **Ask in #observability** Slack with:
   - Error message
   - Monitor/SLO link
   - Steps attempted

3. **Tag @github/observability** in PR if deployment blocked

4. **Check DataDog status**: [status.datadoghq.com](https://status.datadoghq.com)

---

## Prevention Best Practices

1. **Merge PRs promptly** (within 24 hours)
2. **Test queries in Metrics Explorer** before adding to monitors
3. **Create in UI first** for complex monitors, then import to repo
4. **Keep threshold values in sync** between query and YAML
5. **Check for template control** before editing monitors
6. **Use `.ddimport` chatops** as backup for failed automation
7. **Review deployment logs** for all errors, not just the first one
8. **Document custom configurations** in monitor messages

Remember: Most issues can be resolved by understanding the relationship between DataDog UI, the repository, and the automation that syncs them. When in doubt, reach out to @github/observability!
