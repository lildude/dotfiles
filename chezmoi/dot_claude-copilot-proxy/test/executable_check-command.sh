#!/usr/bin/env bash
# test/check-command.sh - Verify a command is available in PATH
# Usage: check-command.sh <command>

set -euo pipefail

CMD="$1"

if ! command -v "$CMD" &>/dev/null; then
    echo "Command not found: $CMD"
    exit 1
fi

# Show version if available
if [[ "$CMD" == "litellm" ]]; then
    version=$(litellm --version 2>/dev/null || echo "unknown")
    echo "litellm version: $version"
fi

exit 0
