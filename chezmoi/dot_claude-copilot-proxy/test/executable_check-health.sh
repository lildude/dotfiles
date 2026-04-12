#!/usr/bin/env bash
# test/check-health.sh - Verify proxy health endpoint responds

set -euo pipefail

PROXY_PORT="${PROXY_PORT:-4000}"
PROXY_URL="http://localhost:$PROXY_PORT"

# Try health endpoint
response=$(curl -s -o /dev/null -w "%{http_code}" "$PROXY_URL/health" --max-time 5 2>/dev/null) || true

if [[ "$response" == "200" ]]; then
    echo "Health endpoint returned 200 OK"
    exit 0
fi

# Some LiteLLM versions use different endpoints
response=$(curl -s -o /dev/null -w "%{http_code}" "$PROXY_URL/" --max-time 5 2>/dev/null) || true

if [[ "$response" =~ ^(200|307|404)$ ]]; then
    echo "Proxy is responding (HTTP $response)"
    exit 0
fi

echo "Proxy not responding at $PROXY_URL (HTTP $response)"
exit 1
