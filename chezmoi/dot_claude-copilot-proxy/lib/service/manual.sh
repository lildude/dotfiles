#!/usr/bin/env bash
# lib/service/manual.sh - Manual/container service management (no init system)

PROXY_DIR="${PROXY_DIR:-$HOME/.claude-copilot-proxy}"
PROXY_PORT="${PROXY_PORT:-4000}"

# Add auto-start to shell config
setup_manual() {
    local start_line="pgrep -f \"litellm\" > /dev/null || $PROXY_DIR/bin/start-proxy.sh &"

    if ! grep -qF "start-proxy.sh" "$SHELL_CONFIG" 2>/dev/null; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Auto-start Claude Copilot Proxy" >> "$SHELL_CONFIG"
        echo "$start_line" >> "$SHELL_CONFIG"
        success "Added auto-start to $SHELL_CONFIG"
    else
        success "Auto-start already configured in $SHELL_CONFIG"
    fi
}

# Remove auto-start from shell config
remove_manual() {
    if [[ -f "$SHELL_CONFIG" ]]; then
        # Create temp file without the proxy lines
        grep -v "start-proxy.sh" "$SHELL_CONFIG" | grep -v "Auto-start Claude Copilot Proxy" > "${SHELL_CONFIG}.tmp"
        mv "${SHELL_CONFIG}.tmp" "$SHELL_CONFIG"
        success "Removed auto-start from $SHELL_CONFIG"
    fi
}

# Start proxy manually as background process
start_manual() {
    nohup "$PROXY_DIR/bin/start-proxy.sh" > /tmp/claude-copilot-proxy.log 2>&1 &
    success "Proxy started in background"
}

# Stop proxy by killing process
stop_manual() {
    local pid
    pid=$(lsof -t -i ":$PROXY_PORT" 2>/dev/null) || true

    if [[ -n "$pid" ]]; then
        kill "$pid" 2>/dev/null || true
        success "Proxy stopped (PID $pid)"
    else
        info "Proxy not running"
    fi
}

# Check if proxy is running
manual_status() {
    lsof -i ":$PROXY_PORT" &>/dev/null
}
