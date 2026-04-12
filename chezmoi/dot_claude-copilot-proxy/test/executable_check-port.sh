#!/usr/bin/env bash
# test/check-port.sh - Verify a port is listening
# Usage: check-port.sh <port>

set -euo pipefail

PORT="$1"

if command -v lsof &>/dev/null; then
    if lsof -i ":$PORT" &>/dev/null; then
        pid=$(lsof -t -i ":$PORT" 2>/dev/null | head -1)
        echo "Port $PORT is listening (PID: $pid)"
        exit 0
    fi
elif command -v ss &>/dev/null; then
    if ss -tln | grep -q ":$PORT "; then
        echo "Port $PORT is listening"
        exit 0
    fi
elif command -v netstat &>/dev/null; then
    if netstat -tln | grep -q ":$PORT "; then
        echo "Port $PORT is listening"
        exit 0
    fi
fi

echo "Port $PORT is not listening"
exit 1
