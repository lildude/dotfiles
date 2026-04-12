#!/usr/bin/env bash
# lib/token/main.sh - Token management dispatcher
#
# Provides unified interface for token get/store/validate across platforms
#
# Requires: lib/common.sh and lib/config.sh must be sourced first

PROXY_DIR="${PROXY_DIR:-$HOME/.claude-copilot-proxy}"

# Source platform-specific implementations
source "${PROXY_DIR}/lib/token/macos.sh"
source "${PROXY_DIR}/lib/token/linux.sh"
source "${PROXY_DIR}/lib/token/env.sh"

# Track where token was found
TOKEN_SOURCE=""

# Normalize token from storage/user input.
# - Trims surrounding whitespace
# - Strips optional surrounding single/double quotes
# - Strips optional leading "Bearer " prefix (case-insensitive)
normalize_token() {
    local token="$1"

    # Trim leading/trailing whitespace
    token="$(printf '%s' "$token" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"

    # Strip optional surrounding quotes
    if [[ "$token" =~ ^\".*\"$ ]]; then
        token="${token:1:${#token}-2}"
    elif [[ "$token" =~ ^\'.*\'$ ]]; then
        token="${token:1:${#token}-2}"
    fi

    # Strip optional bearer prefix
    if [[ "$token" =~ ^[Bb][Ee][Aa][Rr][Ee][Rr][[:space:]]+(.+) ]]; then
        token="${BASH_REMATCH[1]}"
    fi

    # Final trim in case prefix removal introduced whitespace
    token="$(printf '%s' "$token" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"

    echo "$token"
}

# Get token from the appropriate source based on platform
# Returns token on stdout, sets TOKEN_SOURCE
get_token() {
    local token=""
    TOKEN_SOURCE=""

    # Try platform-specific secure storage first
    case "${PLATFORM:-}" in
        macos)
            token=$(keychain_get 2>/dev/null)
            [[ -n "$token" ]] && TOKEN_SOURCE="macOS Keychain"
            ;;
        linux)
            token=$(secret_tool_get 2>/dev/null)
            [[ -n "$token" ]] && TOKEN_SOURCE="GNOME Keyring"
            ;;
    esac

    # Fallback to environment variable (all platforms)
    if [[ -z "$token" ]]; then
        token=$(env_get)
        [[ -n "$token" ]] && TOKEN_SOURCE="environment variable (LITELLM_TOKEN)"
    fi

    if [[ -n "$token" ]]; then
        token=$(normalize_token "$token")
    fi

    echo "$token"
}

# Store token using the appropriate method for the platform
store_token() {
    local token="$1"
    token=$(normalize_token "$token")

    case "${PLATFORM:-}" in
        macos)
            keychain_store "$token"
            ;;
        linux)
            if [[ "${IS_CONTAINER:-false}" == "true" ]]; then
                # Containers don't have GNOME Keyring
                env_store "$token"
            elif command_exists secret-tool; then
                secret_tool_store "$token"
            else
                env_store "$token"
            fi
            ;;
        *)
            env_store "$token"
            ;;
    esac

    # Always create the LiteLLM api-key.json file
    create_api_key_file "$token"
}

# Validate token with GitHub Copilot API
validate_token() {
    local token="$1"
    token=$(normalize_token "$token")

    # Basic format check
    if [[ ! "$token" =~ ^(ghp_|github_pat_) ]]; then
        warn "Token doesn't start with 'ghp_' or 'github_pat_'. This may not be a valid GitHub PAT."
        return 1
    fi

    # Test with API
    info "Validating token with GitHub API..."
    local response
    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer $token" \
        -H "Editor-Version: vscode/1.95.0" \
        -H "Copilot-Integration-Id: vscode-chat" \
        "https://api.githubcopilot.com/models" 2>/dev/null) || true

    local http_code
    http_code=$(echo "$response" | tail -n1)

    if [[ "$http_code" == "200" ]]; then
        success "Token validated successfully"
        return 0
    else
        error "Token validation failed (HTTP $http_code)"
        return 1
    fi
}

# Verify token storage is intact
verify_token_storage() {
    local source="$1"

    info "Verifying token exists in $source..."

    case "$source" in
        "macOS Keychain")
            keychain_verify && success "Token verified in macOS Keychain" && return 0
            error "Token not found in macOS Keychain"
            return 1
            ;;
        "GNOME Keyring")
            secret_tool_verify && success "Token verified in GNOME Keyring" && return 0
            error "Token not found in GNOME Keyring"
            return 1
            ;;
        "environment variable (LITELLM_TOKEN)")
            env_verify && success "Token verified in environment variable" && return 0
            error "LITELLM_TOKEN environment variable not set"
            return 1
            ;;
        *)
            warn "Unknown token source: $source"
            return 1
            ;;
    esac
}

# Create LiteLLM api-key.json for GitHub Copilot auth
create_api_key_file() {
    local token="$1"
    local litellm_config_dir="$HOME/.config/litellm/github_copilot"

    mkdir -p "$litellm_config_dir"

    cat > "$litellm_config_dir/api-key.json" << EOF
{
  "token": "$token",
  "expires_at": 4102444800,
  "endpoints": {
    "api": "https://api.githubcopilot.com"
  }
}
EOF

    success "Created LiteLLM api-key.json"
}

# Interactive PAT setup flow
setup_pat() {
    echo -e "\n${BOLD:-}Setting up GitHub PAT...${NC:-}"

    # Check for existing token
    local existing_token
    existing_token=$(get_token)

    if [[ -n "$existing_token" ]]; then
        info "Found existing token in $TOKEN_SOURCE"

        # Silently validate and use if it works
        if validate_token "$existing_token" 2>/dev/null; then
            success "Using existing valid token from $TOKEN_SOURCE"
            # Ensure api-key.json exists even if token was already stored
            create_api_key_file "$existing_token"
            return 0
        else
            warn "Existing token in $TOKEN_SOURCE is invalid or expired"
            if ! prompt_yes_no "Enter a new token?"; then
                info "Keeping existing token (may not work)"
                create_api_key_file "$existing_token"
                return 0
            fi
        fi
    fi

    # Show instructions for creating PAT
    local pat_url="https://github.com/settings/tokens/new?scopes=copilot&description=LiteLLM%20Copilot%20Proxy"

    echo ""
    echo "  Create a GitHub PAT with 'copilot' scope:"
    echo ""
    echo "  $pat_url"
    echo ""
    echo "  1. Set expiration (90 days recommended)"
    echo "  2. Ensure 'copilot' scope is checked"
    echo "  3. Click 'Generate token'"
    echo "  4. Copy the token (starts with ghp_...)"
    echo ""

    local new_token=""
    while [[ -z "$new_token" ]]; do
        read -r -s -p "Paste your token: " new_token
        echo ""

        new_token=$(normalize_token "$new_token")

        if [[ -z "$new_token" ]]; then
            error "Token cannot be empty"
            continue
        fi

        if ! validate_token "$new_token"; then
            if ! prompt_yes_no "Token validation failed. Store anyway?"; then
                new_token=""
            fi
        fi
    done

    store_token "$new_token"
}
