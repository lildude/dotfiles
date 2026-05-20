# Example 3: Missing PR After UI Change

## Issue

Made a change to a monitor in DataDog UI, but the expected auto-generated PR never appeared in `github/datadog-monitoring`.

## Context

- **Monitor**: `myservice/api-latency`
- **Change**: Updated threshold from 500ms to 750ms
- **When**: Changed 2 hours ago
- **Expected**: Hubot should create PR within 5-10 minutes
- **Actual**: No PR created

## Investigation Steps

### Step 1: Wait and Verify
- Waited 2 hours (plenty of time for automation)
- Checked all open PRs: None for this monitor
- Checked closed/merged PRs: None recent
- Conclusion: Automation failed ❌

### Step 2: Verify Monitor Configuration
- **Monitor name**: `myservice/api-latency` ✅ (correct format)
- **Monitor exists in UI**: Yes ✅
- **Monitor ID**: `87654321`
- **My permissions**: Write access to datadog-monitoring repo ✅

### Step 3: Check for Automation Issues
- Checked #observability Slack: No outage notifications
- No other team members reporting issues
- Likely individual failure, not systemic

## Solution Applied

### Option 1: Whitespace Change (Tried First)

1. Opened monitor in DataDog UI
2. Added a space to the message field
3. Saved
4. Waited 10 minutes
5. Result: Still no PR ❌

### Option 2: Manual Chatops Import (Successful)

1. Went to #observability-chatops in Slack
2. Ran command:
   ```
   .ddimport monitor 87654321
   ```
3. Bot response:
   ```
   Creating import PR for monitor myservice/api-latency...
   PR created: https://github.com/github/datadog-monitoring/pull/5678
   ```
4. Result: PR created successfully! ✅

### Step 4: Review and Merge PR

1. Opened PR #5678
2. Verified changes:
   - Threshold updated: 500 → 750 ✅
   - Query updated: `> 500` → `> 750` ✅
   - Critical value updated: `500` → `750` ✅
3. All values in sync ✅
4. Approved and deployed
5. Merged PR

## Why Automation Failed

After checking with Observability team:

- Audit log showed the change was made
- Forwarder had a transient network issue at that time
- Change event wasn't processed by automation
- One-off issue, not systemic

## Prevention

**For users:**
1. If no PR after 10-15 minutes, don't wait hours
2. Use `.ddimport monitor <id>` immediately
3. Confirm PR creation before considering task complete

**For Observability team:**
They added:
1. Monitoring for audit log forwarder
2. Alert on missed events
3. Automatic retry mechanism

## Useful Commands Reference

```bash
# Import monitor by ID
.ddimport monitor <monitor-id>

# Import SLO by ID  
.ddimport slo <slo-id>

# Import dashboard by ID
.ddimport dashboard <dashboard-id>
```

## How to Find Monitor ID

1. **From DataDog URL**:
   ```
   https://app.datadoghq.com/monitors/87654321
                                    ↑
                                Monitor ID
   ```

2. **From monitor JSON**:
   - Edit monitor → JSON tab → Look for `"id": 87654321`

3. **From API**:
   ```bash
   curl "https://api.datadoghq.com/api/v1/monitor" \
     -H "DD-API-KEY: ${DD_API_KEY}" | jq '.[] | select(.name == "myservice/api-latency") | .id'
   ```

## Outcome

✅ PR created via chatops  
✅ Changes reviewed and merged  
✅ Monitor updated in repository  
✅ Team learned about `.ddimport` backup option  

## Key Takeaway

**Don't wait hours for automation**. If PR doesn't appear in 10-15 minutes, use `.ddimport` chatops to force it. This is a supported and reliable backup method.
