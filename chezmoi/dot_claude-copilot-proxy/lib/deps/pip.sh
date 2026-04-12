#!/usr/bin/env bash
# lib/deps/pip.sh - pip dependency installation (fallback for all platforms)
#
# Requires: lib/common.sh must be sourced first (provides info, success, warn, error)

# Install litellm and dependencies with pip
# Used when pipx fails (e.g., uvloop build requires gcc) or in containers
install_with_pip() {
    # Core packages
    local packages=(
        litellm fastapi uvicorn orjson apscheduler cryptography
        email-validator websockets prisma httpx aiohttp
        # Proxy-specific dependencies often missing from base install
        backoff python-multipart fastapi-sso pyjwt
    )

    info "Installing litellm and proxy dependencies with pip..."

    if pip3 install --user --break-system-packages "${packages[@]}" 2>/dev/null; then
        success "Installed with --break-system-packages"
    elif pip3 install --user "${packages[@]}" 2>/dev/null; then
        success "Installed with --user"
    else
        error "pip install failed"
        return 1
    fi

    # Try uvloop if available as prebuilt wheel (skip if would require compilation)
    pip3 install --user --break-system-packages --only-binary :all: uvloop 2>/dev/null || true

    export PATH="$HOME/.local/bin:$PATH"
    return 0
}

# Install jq only (for containers without apt)
install_jq_manual() {
    if command_exists jq; then
        return 0
    fi

    warn "jq not found. Please install manually:"
    echo "  macOS:  brew install jq"
    echo "  Linux:  sudo apt install jq"
    echo "  Alpine: apk add jq"
}
