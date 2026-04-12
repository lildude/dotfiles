#!/usr/bin/env bash
# lib/token/macos.sh - macOS Keychain token storage

KEYCHAIN_SERVICE="${KEYCHAIN_SERVICE:-litellm-copilot-token}"

# Get token from macOS Keychain
keychain_get() {
    local token=""

    if ! command_exists security; then
        return 1
    fi

    # Try with account parameter first (new format)
    token=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -a "$USER" -w 2>/dev/null) || true

    # Fallback: try without account for legacy tokens
    if [[ -z "$token" ]]; then
        token=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -w 2>/dev/null) || true
    fi

    echo "$token"
}

# Store token in macOS Keychain
keychain_store() {
    local token="$1"

    if ! command_exists security; then
        return 1
    fi

    # Delete existing entry if present
    security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "$USER" 2>/dev/null || true

    # Store new token (requires -a account and -s service)
    security add-generic-password -s "$KEYCHAIN_SERVICE" -a "$USER" -w "$token"
    success "Token stored in macOS Keychain"
}

# Delete token from macOS Keychain
keychain_delete() {
    if command_exists security; then
        security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "$USER" 2>/dev/null || true
    fi
}

# Verify token exists in Keychain
keychain_verify() {
    if command_exists security; then
        security find-generic-password -s "$KEYCHAIN_SERVICE" -a "$USER" &>/dev/null
    else
        return 1
    fi
}
