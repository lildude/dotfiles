#!/usr/bin/env bash
# lib/detect.sh - Environment/platform detection

# Exports:
#   PLATFORM      - "macos", "linux"
#   PKG_MANAGER   - "brew", "apt", "pip"
#   INIT_SYSTEM   - "launchd", "systemd", "none"
#   SHELL_CONFIG  - path to shell rc file
#   IS_CONTAINER  - "true" or "false"

detect_platform() {
    echo -e "\n${BOLD:-}Detecting environment...${NC:-}"

    # Detect OS
    case "$(uname -s)" in
        Darwin)
            PLATFORM="macos"
            ;;
        Linux)
            PLATFORM="linux"
            ;;
        *)
            fatal "Unsupported operating system: $(uname -s)"
            ;;
    esac

    # Detect if running in container
    IS_CONTAINER="false"
    if [[ -f /.dockerenv ]] || [[ -n "${CODESPACES:-}" ]] || [[ -n "${REMOTE_CONTAINERS:-}" ]]; then
        IS_CONTAINER="true"
    fi

    # Detect package manager
    if command_exists brew; then
        PKG_MANAGER="brew"
    elif command_exists apt-get; then
        PKG_MANAGER="apt"
    else
        PKG_MANAGER="pip"
    fi

    # Detect init system
    if [[ "$PLATFORM" == "macos" ]]; then
        INIT_SYSTEM="launchd"
    elif [[ "$IS_CONTAINER" == "true" ]]; then
        INIT_SYSTEM="none"
    elif command_exists systemctl && systemctl --user status &>/dev/null; then
        INIT_SYSTEM="systemd"
    else
        INIT_SYSTEM="none"
    fi

    # Detect shell config file
    local shell_name
    shell_name=$(basename "${SHELL:-/bin/bash}")
    case "$shell_name" in
        zsh)  SHELL_CONFIG="$HOME/.zshrc" ;;
        bash) SHELL_CONFIG="$HOME/.bashrc" ;;
        *)    SHELL_CONFIG="$HOME/.profile" ;;
    esac

    # Export for other modules
    export PLATFORM PKG_MANAGER INIT_SYSTEM SHELL_CONFIG IS_CONTAINER

    # Summary
    echo "  Platform:        $PLATFORM"
    echo "  Package manager: $PKG_MANAGER"
    echo "  Init system:     $INIT_SYSTEM"
    echo "  Shell config:    $SHELL_CONFIG"
    echo "  Container:       $IS_CONTAINER"
    success "Environment detected"
}

# Quiet version - no output, just sets variables
detect_platform_quiet() {
    # Detect OS
    case "$(uname -s)" in
        Darwin) PLATFORM="macos" ;;
        Linux)  PLATFORM="linux" ;;
        *)      PLATFORM="unknown" ;;
    esac

    # Detect if running in container
    IS_CONTAINER="false"
    if [[ -f /.dockerenv ]] || [[ -n "${CODESPACES:-}" ]] || [[ -n "${REMOTE_CONTAINERS:-}" ]]; then
        IS_CONTAINER="true"
    fi

    # Detect package manager
    if command_exists brew; then
        PKG_MANAGER="brew"
    elif command_exists apt-get; then
        PKG_MANAGER="apt"
    else
        PKG_MANAGER="pip"
    fi

    # Detect init system
    if [[ "$PLATFORM" == "macos" ]]; then
        INIT_SYSTEM="launchd"
    elif [[ "$IS_CONTAINER" == "true" ]]; then
        INIT_SYSTEM="none"
    elif command_exists systemctl && systemctl --user status &>/dev/null; then
        INIT_SYSTEM="systemd"
    else
        INIT_SYSTEM="none"
    fi

    # Detect shell config file
    local shell_name
    shell_name=$(basename "${SHELL:-/bin/bash}")
    case "$shell_name" in
        zsh)  SHELL_CONFIG="$HOME/.zshrc" ;;
        bash) SHELL_CONFIG="$HOME/.bashrc" ;;
        *)    SHELL_CONFIG="$HOME/.profile" ;;
    esac

    export PLATFORM PKG_MANAGER INIT_SYSTEM SHELL_CONFIG IS_CONTAINER
}
