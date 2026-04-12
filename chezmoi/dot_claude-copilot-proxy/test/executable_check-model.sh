#!/usr/bin/env bash
# test/check-model.sh - Test a model request through the proxy

set -euo pipefail

PROXY_PORT="${PROXY_PORT:-4000}"
PROXY_URL="http://localhost:$PROXY_PORT"
MODEL="${TEST_MODEL:-claude-sonnet-4}"

echo "Testing model: $MODEL"

response=$(curl -s -w "\n%{http_code}" \
    -X POST "$PROXY_URL/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer fake-key" \
    -d "{\"model\": \"$MODEL\", \"messages\": [{\"role\": \"user\", \"content\": \"Say hello in one word.\"}], \"max_tokens\": 10}" \
    --max-time 30 2>/dev/null) || true

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" == "200" ]]; then
    # Try to extract the response content
    content=$(echo "$body" | jq -r '.choices[0].message.content // empty' 2>/dev/null | head -c 50)
    if [[ -n "$content" ]]; then
        echo "Model responded: $content"
        exit 0
    else
        echo "Model returned 200 but no content extracted"
        echo "Response: $body"
        exit 1
    fi
fi

echo "Model request failed (HTTP $http_code)"
echo "Response: $body"
exit 1
