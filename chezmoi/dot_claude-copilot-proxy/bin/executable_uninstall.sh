#!/usr/bin/env bash
# bin/uninstall.sh - Remove Claude Code → GitHub Copilot Proxy
#
# Usage:
#   ./bin/uninstall.sh              # Interactive uninstall
#   ./bin/uninstall.sh --quiet      # Non-interactive (remove all)

set -euo pipefail

# Determine script and proxy directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROXY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
export PROXY_DIR

# Source library modules
source "${PROXY_DIR}/lib/common.sh"
source "${PROXY_DIR}/lib/detect.sh"
source "${PROXY_DIR}/lib/token/macos.sh"
source "${PROXY_DIR}/lib/token/linux.sh"
source "${PROXY_DIR}/lib/service/main.sh"

# Flags
QUIET="${QUIET:-false}"
export QUIET

PROXY_PORT="${PROXY_PORT:-4000}"

# =============================================================================
# Uninstall
# =============================================================================

uninstall() {
    echo -e "\n${BOLD}Uninstalling Claude Code → GitHub Copilot Proxy...${NC}"

    # Detect environment first
    detect_platform

    # Stop and remove services
    echo ""
    info "Removing auto-start service..."
    remove_service

    # Kill any running proxy
    info "Stopping proxy..."
    local pid
    pid=$(lsof -t -i ":$PROXY_PORT" 2>/dev/null) || true
    if [[ -n "$pid" ]]; then
        kill "$pid" 2>/dev/null || true
        success "Stopped proxy process (PID $pid)"
    else
        info "Proxy not running"
    fi

    # Remove token from secure storage
    echo ""
    if prompt_yes_no "Remove stored GitHub PAT?"; then
        case "$PLATFORM" in
            macos)
                keychain_delete
                success "Removed token from Keychain"
                ;;
            linux)
                secret_tool_delete
                success "Removed token from GNOME Keyring"
                ;;
        esac
    fi

    # Remove LiteLLM config
    if [[ -d "$HOME/.config/litellm/github_copilot" ]]; then
        rm -rf "$HOME/.config/litellm/github_copilot"
        success "Removed LiteLLM api-key.json"
    fi

    # Note about shell config (don't auto-remove to avoid breaking things)
    echo ""
    warn "Manual cleanup needed in $SHELL_CONFIG:"
    echo "  Remove lines containing:"
    echo "    - ANTHROPIC_BASE_URL"
    echo "    - ANTHROPIC_AUTH_TOKEN"
    echo "    - LITELLM_TOKEN"
    echo "    - start-proxy.sh"

    # Ask about removing proxy directory
    echo ""
    if prompt_yes_no "Remove $PROXY_DIR? (This will delete all proxy files)"; then
        # Can't delete ourselves while running, so schedule it
        echo ""
        warn "Directory will be removed. Run this to complete:"
        echo "  rm -rf $PROXY_DIR"
    fi

    echo ""
    success "Uninstall complete"
}

# =============================================================================
# Main
# =============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --quiet|-q)
                QUIET=true
                export QUIET
                ;;
            --help|-h)
                echo "Usage: $(basename "$0") [--quiet]"
                echo ""
                echo "Remove Claude Code → GitHub Copilot Proxy"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
        shift
    done

    # Header
    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  Claude Code → GitHub Copilot Proxy Uninstaller           ║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"

    if ! prompt_yes_no "Are you sure you want to uninstall?"; then
        info "Uninstall cancelled"
        exit 0
    fi

    uninstall
}

main "$@"
