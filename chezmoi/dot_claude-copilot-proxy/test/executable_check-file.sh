#!/usr/bin/env bash
# test/check-file.sh - Verify a file exists and is executable
# Usage: check-file.sh <path> [--no-exec]

set -euo pipefail

FILE="$1"
CHECK_EXEC=true

[[ "${2:-}" == "--no-exec" ]] && CHECK_EXEC=false

if [[ ! -f "$FILE" ]]; then
    echo "File not found: $FILE"
    exit 1
fi

if $CHECK_EXEC && [[ ! -x "$FILE" ]]; then
    echo "File not executable: $FILE"
    exit 1
fi

exit 0
