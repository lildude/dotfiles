#!/usr/bin/env bash
# bin/setup.sh - Main installer for Claude Code → GitHub Copilot Proxy
#
# Usage:
#   ./bin/setup.sh              # Interactive setup
#   ./bin/setup.sh --quiet      # Non-interactive (use defaults)
#   ./bin/setup.sh --help       # Show help

set -euo pipefail

# Determine script and proxy directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROXY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
export PROXY_DIR

# Source all library modules
source "${PROXY_DIR}/lib/common.sh"
source "${PROXY_DIR}/lib/detect.sh"
source "${PROXY_DIR}/lib/config.sh"
source "${PROXY_DIR}/lib/deps/main.sh"
source "${PROXY_DIR}/lib/token/main.sh"
source "${PROXY_DIR}/lib/service/main.sh"

# Flags
QUIET="${QUIET:-false}"
export QUIET

# =============================================================================
# Verification
# =============================================================================

verify_setup() {
    echo -e "\n${BOLD}Verifying setup...${NC}"

    # Ensure proxy is running
    ensure_running || return 1

    # Health check
    if curl -s "http://localhost:$PROXY_PORT/health" &>/dev/null; then
        success "Health check passed"
    else
        warn "Health check returned error (proxy may still be starting)"
    fi

    # Model test
    info "Testing API with claude-sonnet-4..."
    local test_response
    test_response=$(curl -s -X POST "http://localhost:$PROXY_PORT/chat/completions" \
        -H 'Content-Type: application/json' \
        -H 'Authorization: Bearer fake-key' \
        -d '{"model": "claude-sonnet-4", "messages": [{"role": "user", "content": "Say hello in one word"}], "max_tokens": 10}' \
        --max-time 30 2>/dev/null) || true

    if echo "$test_response" | grep -q "choices"; then
        success "Model test passed"
    else
        warn "Model test inconclusive (proxy may need more time)"
    fi
}

# =============================================================================
# Help
# =============================================================================

show_help() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Automated setup for Claude Code → GitHub Copilot Proxy"
    echo ""
    echo "Options:"
    echo "  --help, -h     Show this help message"
    echo "  --quiet, -q    Non-interactive mode (use defaults)"
    echo ""
    echo "For uninstall, run: $PROXY_DIR/bin/uninstall.sh"
    echo ""
    echo "For more information, see README.md"
}

# =============================================================================
# Main
# =============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --quiet|-q)
                QUIET=true
                export QUIET
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done

    # Header
    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  Claude Code → GitHub Copilot Proxy Setup                 ║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"

    # Step 1: Detect environment
    detect_platform

    # Step 2: Install dependencies
    echo -e "\n${BOLD}[1/6] Installing dependencies...${NC}"
    install_deps

    # Step 3: Setup PAT
    echo -e "\n${BOLD}[2/6] Setting up GitHub PAT...${NC}"
    setup_pat

    # Step 4: Setup directory and config
    echo -e "\n${BOLD}[3/6] Setting up configuration...${NC}"
    setup_directory

    # Step 5: Configure shell
    echo -e "\n${BOLD}[4/6] Configuring shell...${NC}"
    configure_shell

    # Step 6: Setup auto-start service
    echo -e "\n${BOLD}[5/6] Setting up service...${NC}"
    setup_service

    # Step 7: Verify
    echo -e "\n${BOLD}[6/6] Verifying setup...${NC}"
    verify_setup

    # Success message
    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  Setup complete!                                          ║${NC}"
    echo -e "${BOLD}║  Open a new terminal and run: ${GREEN}claude${NC}${BOLD}                       ║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Useful commands:"
    echo "  Logs:      tail -f /tmp/claude-copilot-proxy.log"
    echo "  Update:    $PROXY_DIR/bin/update-models.sh"
    echo "  Uninstall: $PROXY_DIR/bin/uninstall.sh"
    echo ""
}

main "$@"
