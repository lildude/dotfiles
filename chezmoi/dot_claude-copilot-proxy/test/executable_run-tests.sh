#!/usr/bin/env bash
# test/run-tests.sh - Run all verification tests for the Claude Copilot Proxy
#
# Usage:
#   ./test/run-tests.sh           # Run all tests
#   ./test/run-tests.sh --quick   # Skip slow tests (API calls)
#   ./test/run-tests.sh --verbose # Show detailed output

# Note: -e (errexit) is intentionally omitted - we want to continue running
# tests even when individual tests fail, and report results at the end.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROXY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Counters
PASSED=0
FAILED=0
SKIPPED=0

# Flags
QUICK=false
VERBOSE=false
PROXY_PORT="${PROXY_PORT:-4000}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --quick) QUICK=true ;;
        --verbose) VERBOSE=true ;;
        --help|-h)
            echo "Usage: $(basename "$0") [--quick] [--verbose]"
            echo ""
            echo "Options:"
            echo "  --quick    Skip slow tests (API calls)"
            echo "  --verbose  Show detailed output"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# =============================================================================
# Test Helpers
# =============================================================================

log_test() {
    echo -e "${BLUE}[TEST]${NC} $*"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $*"
    ((PASSED++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $*"
    ((FAILED++))
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $*"
    ((SKIPPED++))
}

# Run a test - accepts name followed by command and args
# Usage: run_test "Test name" script.sh arg1 arg2
run_test() {
    local name="$1"
    shift
    local cmd=("$@")

    log_test "$name"

    local output

    if $VERBOSE; then
        if "${cmd[@]}"; then
            log_pass "$name"
        else
            log_fail "$name"
        fi
    else
        # Capture exit code before || true consumes it
        if output=$("${cmd[@]}" 2>&1); then
            log_pass "$name"
        else
            log_fail "$name"
        fi
    fi
}

# =============================================================================
# Tests
# =============================================================================

echo ""
echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Claude Copilot Proxy - Test Suite                        ║${NC}"
echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# --- File Structure Tests ---
echo -e "${BOLD}File Structure${NC}"
echo "------------------------------------------------------------"

run_test "bin/setup.sh exists and is executable" "$SCRIPT_DIR/check-file.sh" "$PROXY_DIR/bin/setup.sh"
run_test "bin/start-proxy.sh exists and is executable" "$SCRIPT_DIR/check-file.sh" "$PROXY_DIR/bin/start-proxy.sh"
run_test "bin/update-models.sh exists and is executable" "$SCRIPT_DIR/check-file.sh" "$PROXY_DIR/bin/update-models.sh"
run_test "bin/uninstall.sh exists and is executable" "$SCRIPT_DIR/check-file.sh" "$PROXY_DIR/bin/uninstall.sh"
run_test "config.yaml exists" "$SCRIPT_DIR/check-file.sh" "$PROXY_DIR/config.yaml" "--no-exec"
run_test "lib/common.sh exists" "$SCRIPT_DIR/check-file.sh" "$PROXY_DIR/lib/common.sh" "--no-exec"

echo ""

# --- Syntax Tests ---
echo -e "${BOLD}Bash Syntax${NC}"
echo "------------------------------------------------------------"

run_test "All scripts have valid syntax" "$SCRIPT_DIR/check-syntax.sh"

echo ""

# --- Dependencies Tests ---
echo -e "${BOLD}Dependencies${NC}"
echo "------------------------------------------------------------"

run_test "jq is installed" "$SCRIPT_DIR/check-command.sh" "jq"
run_test "curl is installed" "$SCRIPT_DIR/check-command.sh" "curl"
run_test "litellm is installed" "$SCRIPT_DIR/check-command.sh" "litellm"

echo ""

# --- Token Tests ---
echo -e "${BOLD}Token Storage${NC}"
echo "------------------------------------------------------------"

run_test "GitHub PAT is accessible" "$SCRIPT_DIR/check-token.sh"

echo ""

# --- Environment Tests ---
echo -e "${BOLD}Environment Variables${NC}"
echo "------------------------------------------------------------"

run_test "ANTHROPIC_BASE_URL points to local proxy" "$SCRIPT_DIR/check-env.sh" "ANTHROPIC_BASE_URL" "http://localhost:$PROXY_PORT"
run_test "ANTHROPIC_AUTH_TOKEN is set" "$SCRIPT_DIR/check-env.sh" "ANTHROPIC_AUTH_TOKEN"
run_test "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS is set" "$SCRIPT_DIR/check-env.sh" "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS" "1"

echo ""

# --- Proxy Tests ---
echo -e "${BOLD}Proxy Status${NC}"
echo "------------------------------------------------------------"

run_test "Proxy port 4000 is listening" "$SCRIPT_DIR/check-port.sh" "4000"
run_test "Proxy health endpoint responds" "$SCRIPT_DIR/check-health.sh"

echo ""

# --- API Tests (slow) ---
if $QUICK; then
    echo -e "${BOLD}API Tests${NC} ${YELLOW}(skipped - use without --quick to run)${NC}"
    echo "------------------------------------------------------------"
    log_skip "Token validation with GitHub API"
    log_skip "Model request through proxy"
else
    echo -e "${BOLD}API Tests${NC}"
    echo "------------------------------------------------------------"

    run_test "Token validates with GitHub Copilot API" "$SCRIPT_DIR/check-token-api.sh"
    run_test "Model request succeeds through proxy" "$SCRIPT_DIR/check-model.sh"
fi

echo ""

# =============================================================================
# Summary
# =============================================================================

echo "------------------------------------------------------------"
TOTAL=$((PASSED + FAILED + SKIPPED))
echo -e "${BOLD}Results:${NC} ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, ${YELLOW}$SKIPPED skipped${NC} (total: $TOTAL)"
echo ""

if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}Some tests failed. Run with --verbose for details.${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
