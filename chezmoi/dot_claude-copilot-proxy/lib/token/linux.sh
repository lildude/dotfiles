#!/usr/bin/env bash
# lib/token/linux.sh - Linux secret-tool (GNOME Keyring) token storage

KEYCHAIN_SERVICE="${KEYCHAIN_SERVICE:-litellm-copilot-token}"

# Get token from GNOME Keyring via secret-tool
secret_tool_get() {
    local token=""

    if ! command_exists secret-tool; then
        return 1
    fi

    token=$(secret-tool lookup service "$KEYCHAIN_SERVICE" username token 2>/dev/null) || true
    echo "$token"
}

# Store token in GNOME Keyring via secret-tool
secret_tool_store() {
    local token="$1"

    if ! command_exists secret-tool; then
        return 1
    fi

    echo "$token" | secret-tool store --label="LiteLLM Copilot Token" service "$KEYCHAIN_SERVICE" username token
    success "Token stored in GNOME Keyring"
}

# Delete token from GNOME Keyring
secret_tool_delete() {
    if command_exists secret-tool; then
        secret-tool clear service "$KEYCHAIN_SERVICE" username token 2>/dev/null || true
    fi
}

# Verify token exists in GNOME Keyring
secret_tool_verify() {
    if command_exists secret-tool; then
        secret-tool lookup service "$KEYCHAIN_SERVICE" username token &>/dev/null
    else
        return 1
    fi
}
