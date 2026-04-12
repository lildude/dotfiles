#!/usr/bin/env bash
# test/check-syntax.sh - Verify all bash scripts have valid syntax

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROXY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

errors=0

# Check all .sh files
while IFS= read -r -d '' script; do
    if ! bash -n "$script" 2>&1; then
        echo "Syntax error in: $script"
        ((errors++))
    fi
done < <(find "$PROXY_DIR" -name "*.sh" -type f -print0 2>/dev/null)

if [[ $errors -gt 0 ]]; then
    echo "$errors file(s) with syntax errors"
    exit 1
fi

exit 0
