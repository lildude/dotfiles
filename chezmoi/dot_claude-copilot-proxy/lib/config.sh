#!/usr/bin/env bash
# lib/config.sh - Directory setup and shell configuration

PROXY_DIR="${PROXY_DIR:-$HOME/.claude-copilot-proxy}"
PROXY_PORT="${PROXY_PORT:-4000}"

# Add a line to shell config if not already present
add_to_shell_config() {
    local line="$1"

    # Skip if already present
    if grep -qF "$line" "$SHELL_CONFIG" 2>/dev/null; then
        return 0
    fi

    # Add marker comment and line
    echo "" >> "$SHELL_CONFIG"
    echo "# Claude Code -> GitHub Copilot Proxy" >> "$SHELL_CONFIG"
    echo "$line" >> "$SHELL_CONFIG"
}

# Ensure a shell export exists with the expected value.
# Returns 0 if a change was made, 1 if already correct.
set_shell_export() {
    local var_name="$1"
    local value="$2"
    local desired_line="export ${var_name}=\"${value}\""

    # Already configured exactly as expected
    if grep -qF "$desired_line" "$SHELL_CONFIG" 2>/dev/null; then
        return 1
    fi

    # Replace existing assignments for this variable
    if grep -Eq "^[[:space:]]*(export[[:space:]]+)?${var_name}=" "$SHELL_CONFIG" 2>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        awk -v var_name="$var_name" -v desired_line="$desired_line" '
            BEGIN { replaced = 0 }
            {
                if ($0 ~ "^[[:space:]]*(export[[:space:]]+)?" var_name "=") {
                    if (!replaced) {
                        print desired_line
                        replaced = 1
                    }
                    next
                }
                print
            }
            END {
                if (!replaced) {
                    print desired_line
                }
            }
        ' "$SHELL_CONFIG" > "$tmp_file"
        mv "$tmp_file" "$SHELL_CONFIG"
    else
        add_to_shell_config "$desired_line"
    fi

    return 0
}

# Configure shell environment variables
configure_shell() {
    echo -e "\n${BOLD:-}Configuring shell environment...${NC:-}"

    local changes_made=false

    # Ensure ANTHROPIC_BASE_URL points to local proxy
    if set_shell_export "ANTHROPIC_BASE_URL" "http://localhost:$PROXY_PORT"; then
        changes_made=true
    fi

    # Ensure ANTHROPIC_AUTH_TOKEN is set for local proxy auth
    if set_shell_export "ANTHROPIC_AUTH_TOKEN" "fake-key"; then
        changes_made=true
    fi

    # Disable experimental beta headers from Claude Code to avoid provider-side
    # unsupported beta flag errors when routed through GitHub Copilot.
    if set_shell_export "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS" "1"; then
        changes_made=true
    fi

    if $changes_made; then
        success "Updated environment variables in $SHELL_CONFIG"
    else
        success "Environment variables already configured"
    fi

    # Export in current shell
    export ANTHROPIC_BASE_URL="http://localhost:$PROXY_PORT"
    export ANTHROPIC_AUTH_TOKEN="fake-key"
    export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS="1"
}

# Setup proxy directory and copy config files
setup_directory() {
    echo -e "\n${BOLD:-}Setting up proxy configuration...${NC:-}"

    # Directory already exists (we're running from it)
    success "Proxy directory: $PROXY_DIR"

    # Ensure config.yaml exists (copy from example if needed)
    if [[ ! -f "$PROXY_DIR/config.yaml" ]] && [[ -f "$PROXY_DIR/config.yaml.example" ]]; then
        cp "$PROXY_DIR/config.yaml.example" "$PROXY_DIR/config.yaml"
        success "Created config.yaml from example"
    elif [[ -f "$PROXY_DIR/config.yaml" ]]; then
        success "config.yaml exists"
    else
        fatal "No config.yaml or config.yaml.example found"
    fi

    # Ensure bin scripts are executable
    for script in "$PROXY_DIR/bin/"*.sh; do
        [[ -e "$script" ]] || break
        chmod +x "$script"
    done

    success "Configuration files ready"
}
