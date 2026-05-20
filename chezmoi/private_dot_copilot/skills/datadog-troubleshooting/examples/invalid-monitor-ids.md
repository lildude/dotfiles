# Example 1: Invalid Monitor IDs in SLO

## Error Message

```
Invalid payload: invalid monitor ids: 12345678, monitors not found or not supported SLO
```

## Context

- **What happened**: Deploying an SLO configuration that references monitors
- **Where**: CI/CD pipeline for `github/datadog-monitoring` repo
- **Impact**: SLO deployment blocked

## Root Cause

The SLO references monitor ID `12345678` which no longer exists in DataDog. This happens when:
1. Monitor was manually deleted
2. Monitor PR wasn't merged within 24 hours (auto-deleted)
3. Monitor was removed from repository

## Investigation Steps

1. **Check if monitor exists**:
   - Visit DataDog monitors page
   - Search for ID `12345678`
   - Result: Not found ❌

2. **Check DataDog Archive**:
   - Go to [monitors/settings/archive](https://app.datadoghq.com/monitors/settings/archive)
   - Search for `12345678`
   - Result: Found! ✅ (Deleted 2 days ago due to unmerged PR)

3. **Check for open PRs**:
   - Search `github/datadog-monitoring` PRs
   - Find: PR #1234 "Import monitor service/check-health"
   - Status: Approved but not merged

## Solution Applied

**Step 1: Restore Monitor**
- Visited archive link
- Clicked monitor `12345678`
- Clicked "Restore" button
- Monitor restored successfully ✅

**Step 2: Merge Existing PR**
- Found PR #1234
- Verified configuration
- Deployed and merged PR
- Monitor now tracked in repository ✅

**Step 3: Re-deploy SLO**
- Re-ran deployment for SLO
- SLO now references valid monitor ID
- Deployment successful ✅

## Prevention

- Set up reminder to merge monitor PRs within 24 hours
- Add "monitor-import" label to PRs for visibility
- Review all dependent SLOs before deleting monitors

## Outcome

✅ Monitor restored and tracked in repository  
✅ SLO deployment successful  
✅ Alert routing working as expected  
