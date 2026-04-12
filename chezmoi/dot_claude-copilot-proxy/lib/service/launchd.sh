#!/usr/bin/env bash
# lib/service/launchd.sh - macOS launchd service management

PROXY_DIR="${PROXY_DIR:-$HOME/.claude-copilot-proxy}"
LAUNCHD_LABEL="${LAUNCHD_LABEL:-com.claude-copilot-proxy}"

# Create and load launchd plist
setup_launchd() {
    local plist_dir="$HOME/Library/LaunchAgents"
    local plist_file="$plist_dir/$LAUNCHD_LABEL.plist"

    mkdir -p "$plist_dir"

    cat > "$plist_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LAUNCHD_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$PROXY_DIR/bin/start-proxy.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/claude-copilot-proxy.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/claude-copilot-proxy.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
EOF

    # Unload if already loaded
    launchctl unload "$plist_file" 2>/dev/null || true

    # Load and start
    launchctl load "$plist_file"
    launchctl start "$LAUNCHD_LABEL"

    success "launchd service installed and started"
}

# Stop and remove launchd service
remove_launchd() {
    local plist_file="$HOME/Library/LaunchAgents/$LAUNCHD_LABEL.plist"

    launchctl stop "$LAUNCHD_LABEL" 2>/dev/null || true
    launchctl unload "$plist_file" 2>/dev/null || true
    rm -f "$plist_file"

    success "launchd service removed"
}

# Restart launchd service
restart_launchd() {
    launchctl kickstart -k "gui/$(id -u)/$LAUNCHD_LABEL"
}

# Check if launchd service is running
launchd_status() {
    launchctl list | grep -q "$LAUNCHD_LABEL"
}
