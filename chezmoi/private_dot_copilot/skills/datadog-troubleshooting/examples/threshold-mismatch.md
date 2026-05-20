# Example 2: Threshold Mismatch Error

## Error Message

```
Alert threshold (10) does not match that used in the query (5)
```

## Context

- **What happened**: Updated monitor threshold in YAML but forgot to update query
- **Where**: PR review in `github/datadog-monitoring`
- **Impact**: Deployment failed, monitor not updated

## The Problem

**Original monitor config:**
```yaml
high-error-count:
  priority: 2
  type: metric alert
  query: sum(last_5m):sum:myservice.errors{*}.as_count() > 5
  message: |
    {{#is_alert}}
    Error count is high!
    {{/is_alert}}
  critical: 5
```

**Changed to (incorrectly):**
```yaml
high-error-count:
  priority: 2
  type: metric alert
  query: sum(last_5m):sum:myservice.errors{*}.as_count() > 5  # ❌ Still 5
  message: |
    {{#is_alert}}
    Error count is high!
    {{/is_alert}}
  critical: 10  # ❌ Changed to 10, but query still has 5!
```

## Root Cause

When updating the alert threshold, I changed `critical: 10` but forgot to update the `> 5` in the query string to `> 10`.

DataDog requires these values to match exactly.

## Solution Applied

**Step 1: Identify Mismatch**
- Query threshold: `> 5`
- Critical value: `10`
- These must match!

**Step 2: Decide Correct Value**
- Team decided threshold should be 10 (not 5)
- Need to update query to match

**Step 3: Fix Configuration**
```yaml
high-error-count:
  priority: 2
  type: metric alert
  query: sum(last_5m):sum:myservice.errors{*}.as_count() > 10  # ✅ Updated to 10
  message: |
    {{#is_alert}}
    Error count is high!
    {{/is_alert}}
  critical: 10  # ✅ Matches query now
```

**Step 4: Deploy**
- Updated PR with fix
- CI passed ✅
- Deployed successfully

## Prevention Strategy

1. **Search and replace**: When changing thresholds, search for both occurrences
   ```bash
   # Before changing, find all instances
   grep -n "5" monitors/myservice.yaml
   ```

2. **Code review checklist**: Add item "Threshold values match between query and critical field"

3. **Pre-commit hook**: Could add validation script
   ```bash
   # Extract query threshold and critical value, compare them
   python validate_thresholds.py
   ```

4. **Testing**: Use DataDog UI to test query first, then export to YAML

## Lesson Learned

DataDog monitors have **two** places where threshold appears:
1. In the query string: `> X`
2. In the critical field: `critical: X`

Both must be updated together, always.

## Quick Fix Template

If you encounter this error:

1. Extract both values from error message
2. Decide which is correct
3. Update the incorrect one to match
4. Redeploy

```bash
# Quick check in your YAML
grep -A3 "query:.*>" yourfile.yaml | grep "critical:"
```

## Outcome

✅ Threshold values synchronized  
✅ Monitor deployed successfully  
✅ Team added threshold validation to PR template  
