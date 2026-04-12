#!/usr/bin/env bash
# lib/service/systemd.sh - Linux systemd user service management

PROXY_DIR="${PROXY_DIR:-$HOME/.claude-copilot-proxy}"
SYSTEMD_SERVICE="${SYSTEMD_SERVICE:-claude-copilot-proxy}"

# Create and enable systemd user service
setup_systemd() {
    local service_dir="$HOME/.config/systemd/user"
    local service_file="$service_dir/$SYSTEMD_SERVICE.service"

    mkdir -p "$service_dir"

    cat > "$service_file" << EOF
[Unit]
Description=Claude Code -> GitHub Copilot Proxy
After=network.target

[Service]
Type=simple
Environment="LITELLM_TOKEN=${LITELLM_TOKEN:-}"
ExecStart=$PROXY_DIR/bin/start-proxy.sh
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable "$SYSTEMD_SERVICE"
    systemctl --user start "$SYSTEMD_SERVICE"

    success "systemd service installed and started"
}

# Stop and remove systemd service
remove_systemd() {
    systemctl --user stop "$SYSTEMD_SERVICE" 2>/dev/null || true
    systemctl --user disable "$SYSTEMD_SERVICE" 2>/dev/null || true
    rm -f "$HOME/.config/systemd/user/$SYSTEMD_SERVICE.service"
    systemctl --user daemon-reload

    success "systemd service removed"
}

# Restart systemd service
restart_systemd() {
    systemctl --user restart "$SYSTEMD_SERVICE"
}

# Check if systemd service is running
systemd_status() {
    systemctl --user is-active "$SYSTEMD_SERVICE" &>/dev/null
}
