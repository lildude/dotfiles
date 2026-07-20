# Zero-Token Polling Technique

## The Problem

When an agent needs to wait for an external event (like a code review), there are two naive approaches:

1. **LLM polling loop**: The agent repeatedly calls a tool, checks the result, and decides whether to keep waiting. Each iteration costs a full LLM inference turn.
2. **Sleep in tool call**: The agent calls a tool that blocks for a long time. This ties up a tool execution slot and may hit timeouts.

Both waste resources.

## The Solution: Async Shell + read_bash

The Copilot CLI agent has a built-in mechanism that enables zero-token polling:

1. **`bash(mode="async")`**: Launches a shell command that runs independently of the LLM. Returns a `shellId`.
2. **`read_bash(shellId, delay=N)`**: Waits `N` seconds, then reads any output the shell has produced. The LLM is **not invoked** during those `N` seconds.

By combining these:

```
Turn 1: bash(command="./poll.sh", mode="async")  → shellId="abc123"
Turn 2: read_bash(shellId="abc123", delay=120)    → "" (no output yet, script still running)
Turn 3: read_bash(shellId="abc123", delay=120)    → "REVIEW_COMPLETE\n..."  (done!)
```

- **Turn 1** costs one LLM inference (to decide to launch the script)
- **Turn 2** costs one LLM inference (to decide to check back), but the 120s delay is free
- **Turn 3** costs one LLM inference (to process the result)

Total: ~3 LLM turns for potentially 5+ minutes of waiting. Without this technique, polling every 30s for 5 minutes would cost ~10 LLM turns.

## Why the Shell Script Stays Silent

The polling script intentionally produces **no output** while polling. This is critical because:

- `read_bash` returns whatever the script has printed since the last read
- If the script printed progress updates, the agent would see them and potentially waste a turn processing them
- By only printing when the review is found (or on timeout), we ensure the agent only wakes up when there's something actionable

## Script Design Pattern

```bash
#!/bin/bash
# Good: silent polling, output only on completion
while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
    RESULT=$(check_for_event)
    if [ -n "$RESULT" ]; then
        echo "EVENT_DETECTED"      # Only output on success
        echo "$RESULT"
        exit 0
    fi
    sleep "$INTERVAL"              # Silent wait
    ELAPSED=$((ELAPSED + INTERVAL))
done
echo "TIMEOUT"                     # Only output on timeout
exit 1
```

```bash
# Bad: chatty polling wastes agent turns
while true; do
    echo "Still waiting..."        # DON'T DO THIS - triggers agent processing
    RESULT=$(check_for_event)
    ...
done
```

## Choosing read_bash Delay

The `delay` parameter in `read_bash` controls how long the LLM sleeps before checking:

| Scenario | Recommended delay | Reasoning |
|----------|-------------------|-----------|
| Copilot code review | 120s | Reviews take 1-5 min typically |
| CI checks | 60s | Checks can be faster |
| Long-running build | 180s | Builds can take 10+ min |

Longer delays = fewer LLM turns = lower cost, but slower response time after the event occurs.

## Comparison with Other Approaches

| Approach | Tokens per 5 min wait | Responsiveness |
|----------|----------------------|----------------|
| LLM polling (30s) | ~10 turns | Immediate |
| Async shell + read_bash (120s) | ~3 turns | ≤2 min lag |
| Async shell + read_bash (300s) | ~2 turns | ≤5 min lag |
| Webhook-based | 1 turn | Immediate |

The async shell approach is the sweet spot: very low cost with acceptable latency.
