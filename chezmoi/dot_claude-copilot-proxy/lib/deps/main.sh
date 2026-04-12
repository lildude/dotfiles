#!/usr/bin/env bash
# lib/deps/main.sh - Dependency installation dispatcher

PROXY_DIR="${PROXY_DIR:-$HOME/.claude-copilot-proxy}"

# Source platform-specific implementations
source "${PROXY_DIR}/lib/deps/brew.sh"
source "${PROXY_DIR}/lib/deps/apt.sh"
source "${PROXY_DIR}/lib/deps/pip.sh"

# Install all dependencies based on detected platform
install_deps() {
    echo -e "\n${BOLD:-}Installing dependencies...${NC:-}"

    local install_success=false

    case "${PKG_MANAGER:-pip}" in
        brew)
            if install_with_brew; then
                install_success=true
            else
                # Fallback to pip
                install_with_pip && install_success=true
            fi
            ;;
        apt)
            if install_with_apt; then
                install_success=true
            else
                # Fallback to pip
                install_with_pip && install_success=true
            fi
            ;;
        pip)
            install_jq_manual
            install_with_pip && install_success=true
            ;;
    esac

    # Ensure PATH includes local bin
    export PATH="$HOME/.local/bin:$PATH"

    # Verify installation
    if command_exists litellm; then
        local version
        version=$(litellm --version 2>/dev/null || echo "version unknown")
        success "Dependencies installed (litellm $version)"
        return 0
    else
        if $install_success; then
            warn "litellm installed but not in PATH. You may need to restart your shell."
            return 0
        else
            fatal "Failed to install litellm. Please install manually."
        fi
    fi
}

# Check if all required dependencies are present
check_deps() {
    local missing=()

    command_exists jq || missing+=("jq")
    command_exists curl || missing+=("curl")
    command_exists litellm || missing+=("litellm")

    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing dependencies: ${missing[*]}"
        return 1
    fi

    return 0
}
