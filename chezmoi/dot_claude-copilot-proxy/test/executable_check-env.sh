#!/usr/bin/env bash
# test/check-env.sh - Verify an environment variable is set
# Usage: check-env.sh <VAR_NAME> [expected_value]

set -euo pipefail

VAR_NAME="$1"
EXPECTED="${2:-}"

VALUE="${!VAR_NAME:-}"

if [[ -z "$VALUE" ]]; then
    echo "$VAR_NAME is not set"
    exit 1
fi

if [[ -n "$EXPECTED" ]] && [[ "$VALUE" != "$EXPECTED" ]]; then
    echo "$VAR_NAME='$VALUE' (expected '$EXPECTED')"
    exit 1
fi

echo "$VAR_NAME='$VALUE'"
exit 0
