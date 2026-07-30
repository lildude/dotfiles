#!/usr/bin/env bash
# watch-code-review.sh — wait for a Copilot Code Review (CCR) to land on a PR.
#
# Usage:
#   watch-code-review.sh <owner/repo> <pr_number> [interval_seconds] [timeout_seconds]
#   watch-code-review.sh <pr_url>                  [interval_seconds] [timeout_seconds]
#
# Designed for the zero-token async pattern: launch with bash(mode="async") and
# read with read_bash(shellId, delay=120). The script stays SILENT on stdout
# while polling and prints only when the review lands or the timeout expires, so
# the agent is not invoked during the wait. Diagnostics go to stderr.
#
# Output (stdout, terminal only):
#   REVIEW_COMPLETE + state + summary body + inline comments (path:line | body) -> exit 0
#   TIMEOUT                                                                     -> exit 1
#   guard failure (auth / PR not found)                                         -> exit 2
#
# Defaults: interval 30s, timeout 3600s (1h).
set -uo pipefail

# --- dependency preflight ---
for dep in gh jq; do
  command -v "$dep" >/dev/null 2>&1 || { echo "missing required dependency: $dep" >&2; exit 2; }
done

# Login variants the Copilot reviewer posts under.
CCR_RE='^(copilot|copilot-pull-request-reviewer(\[bot\])?|github-copilot\[bot\])$'

# --- parse args (accept a PR URL as the first arg) ---
if [[ "${1:-}" =~ ^https?://github\.com/([^/]+/[^/]+)/pull/([0-9]+) ]]; then
  REPO="${BASH_REMATCH[1]}"; PR="${BASH_REMATCH[2]}"; shift
else
  REPO="${1:-}"; PR="${2:-}"
  if [ -z "$REPO" ] || [ -z "$PR" ]; then
    echo "usage: watch-code-review.sh <owner/repo> <pr_number> [interval] [timeout]  (or a PR url)" >&2
    exit 2
  fi
  shift 2
fi
INTERVAL="${1:-30}"
TIMEOUT="${2:-3600}"

# validate the numeric args (a non-integer interval would busy-loop; a bad timeout would mis-report)
case "$INTERVAL" in ''|*[!0-9]*) echo "interval must be a positive integer (got '$INTERVAL')" >&2; exit 2 ;; esac
case "$TIMEOUT"  in ''|*[!0-9]*) echo "timeout must be a non-negative integer (got '$TIMEOUT')" >&2; exit 2 ;; esac
[ "$INTERVAL" -gt 0 ] || { echo "interval must be > 0" >&2; exit 2; }

# --- fast-fail guards (a quick fail beats a silent 1-hour no-op) ---
gh auth status >/dev/null 2>&1 || { echo "not authenticated (run: gh auth login)" >&2; exit 2; }
gh pr view "$PR" --repo "$REPO" >/dev/null 2>&1 || { echo "PR #$PR not found in $REPO" >&2; exit 2; }

# Print the REVIEW_COMPLETE block and exit 0 if a Copilot review has landed; else return 1.
emit_review_if_complete() {
  local state
  state=$(gh pr view "$PR" --repo "$REPO" --json reviews 2>/dev/null \
    | jq -r --arg re "$CCR_RE" \
        '[.reviews[]? | select(.author.login? | strings | test($re;"i"))] | last | .state // empty' 2>/dev/null)
  [ -n "${state:-}" ] || return 1
  echo "REVIEW_COMPLETE"
  echo "state: $state"
  echo "pr: $REPO#$PR"
  echo "--- REVIEW BODY ---"
  gh pr view "$PR" --repo "$REPO" --json reviews 2>/dev/null \
    | jq -r --arg re "$CCR_RE" \
        '[.reviews[]? | select(.author.login? | strings | test($re;"i"))] | last | .body // "(no summary body)"' 2>/dev/null \
    || echo "(could not fetch review body)"
  echo "--- INLINE COMMENTS (latest review) ---"
  gh api "repos/$REPO/pulls/$PR/comments?per_page=100" --paginate --slurp 2>/dev/null \
    | jq -r --arg re "$CCR_RE" \
        'flatten
         | [.[] | select(.user.login? | strings | test($re;"i"))] as $ccr
         | ($ccr | map(.pull_request_review_id // 0) | max // 0) as $latest
         | $ccr[]
         | select((.pull_request_review_id // 0) == $latest)
         | "\(.path):\(.line // .original_line // "?") | \(.body | gsub("\r?\n";" "))"' 2>/dev/null \
    || echo "(could not fetch inline comments)"
  echo "--- END ---"
  exit 0
}

elapsed=0
while [ "$elapsed" -lt "$TIMEOUT" ]; do
  emit_review_if_complete

  # sleep only up to the remaining time so a final partial interval doesn't overshoot TIMEOUT
  step=$INTERVAL
  remaining=$((TIMEOUT - elapsed))
  [ "$step" -gt "$remaining" ] && step=$remaining
  sleep "$step"
  elapsed=$((elapsed + step))
done

# final check: a review may have landed during the last sleep interval
emit_review_if_complete

echo "TIMEOUT"
echo "no Copilot review on $REPO#$PR after ${TIMEOUT}s"
exit 1
