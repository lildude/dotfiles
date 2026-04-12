#!/usr/bin/env bash
# lib/service/main.sh - Service management dispatcher

PROXY_DIR="${PROXY_DIR:-$HOME/.claude-copilot-proxy}"
PROXY_PORT="${PROXY_PORT:-4000}"

# Source platform-specific implementations
source "${PROXY_DIR}/lib/service/launchd.sh"
source "${PROXY_DIR}/lib/service/systemd.sh"
source "${PROXY_DIR}/lib/service/manual.sh"

# Setup auto-start service based on detected init system
setup_service() {
    echo -e "\n${BOLD:-}Setting up auto-start service...${NC:-}"

    if ! prompt_yes_no "Enable auto-start on login?"; then
        info "Skipping auto-start setup"
        return 0
    fi

    case "${INIT_SYSTEM:-none}" in
        launchd)
            setup_launchd
            ;;
        systemd)
            setup_systemd
            ;;
        none)
            setup_manual
            ;;
    esac
}

# Remove auto-start service
remove_service() {
    case "${INIT_SYSTEM:-none}" in
        launchd)
            remove_launchd
            ;;
        systemd)
            remove_systemd
            ;;
        none)
            remove_manual
            ;;
    esac
}

# Restart proxy service
restart_service() {
    case "${INIT_SYSTEM:-none}" in
        launchd)
            restart_launchd
            ;;
        systemd)
            restart_systemd
            ;;
        none)
            stop_manual
            start_manual
            ;;
    esac
}

# Stop proxy service
stop_service() {
    case "${INIT_SYSTEM:-none}" in
        launchd)
            launchctl stop "$LAUNCHD_LABEL" 2>/dev/null || true
            ;;
        systemd)
            systemctl --user stop "$SYSTEMD_SERVICE" 2>/dev/null || true
            ;;
        none)
            stop_manual
            ;;
    esac

    # Also kill any running process on the port
    local pid
    pid=$(lsof -t -i ":$PROXY_PORT" 2>/dev/null) || true
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
}

# Check if proxy is running
service_status() {
    case "${INIT_SYSTEM:-none}" in
        launchd)
            launchd_status
            ;;
        systemd)
            systemd_status
            ;;
        none)
            manual_status
            ;;
    esac
}

# Start proxy if not running
ensure_running() {
    if ! lsof -i ":$PROXY_PORT" &>/dev/null; then
        info "Starting proxy..."
        start_manual

        # Wait for startup
        local attempts=0
        while ! lsof -i ":$PROXY_PORT" &>/dev/null && [[ $attempts -lt 10 ]]; do
            sleep 1
            ((attempts++))
        done
    fi

    if lsof -i ":$PROXY_PORT" &>/dev/null; then
        success "Proxy running on port $PROXY_PORT"
        return 0
    else
        error "Proxy failed to start"
        echo "Check logs: tail -f /tmp/claude-copilot-proxy.log"
        return 1
    fi
}
