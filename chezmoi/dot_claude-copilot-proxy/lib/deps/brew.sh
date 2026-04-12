#!/usr/bin/env bash
# lib/deps/brew.sh - Homebrew dependency installation (macOS)
#
# Requires: lib/common.sh must be sourced first (provides info, success, warn, error, command_exists)

# Find a Python version compatible with uvloop (3.9-3.13, NOT 3.14+)
# Returns the path to a compatible python binary, or "python3" if default is ok
find_compatible_python() {
    # Check default python3 version first
    local default_version
    default_version=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null) || true

    if [[ -n "$default_version" ]] && [[ "${default_version%%.*}" == "3" ]]; then
        local minor="${default_version#3.}"
        if [[ "$minor" -lt 14 ]] && [[ "$minor" -ge 9 ]]; then
            echo "python3"  # Default is compatible
            return 0
        fi
    fi

    # Look for specific Python versions (prefer newest compatible)
    for version in 3.13 3.12 3.11 3.10 3.9; do
        # Apple Silicon path
        local path="/opt/homebrew/opt/python@${version}/bin/python${version}"
        [[ -x "$path" ]] && echo "$path" && return 0

        # Intel Mac path
        path="/usr/local/opt/python@${version}/bin/python${version}"
        [[ -x "$path" ]] && echo "$path" && return 0
    done

    return 1  # No compatible Python found
}

# Install dependencies using Homebrew
install_with_brew() {
    # Install jq if missing
    if ! command_exists jq; then
        info "Installing jq with Homebrew..."
        brew install jq
    fi

    # Install pipx if missing
    if ! command_exists pipx; then
        info "Installing pipx with Homebrew..."
        brew install pipx
        pipx ensurepath
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # Install litellm with pipx
    if ! command_exists litellm; then
        # Find a compatible Python version (uvloop doesn't support 3.14+)
        local python_path
        if ! python_path=$(find_compatible_python); then
            warn "No compatible Python (3.9-3.13) found. Installing python@3.13..."
            brew install python@3.13
            python_path="/opt/homebrew/opt/python@3.13/bin/python3.13"
            # Fallback for Intel Macs
            [[ ! -x "$python_path" ]] && python_path="/usr/local/opt/python@3.13/bin/python3.13"
        fi

        info "Installing litellm with pipx..."
        local install_cmd
        if [[ "$python_path" == "python3" ]]; then
            install_cmd="pipx install 'litellm[proxy]'"
        else
            info "Using $python_path (Python 3.14+ has uvloop compatibility issues)"
            install_cmd="pipx install --python '$python_path' 'litellm[proxy]'"
        fi

        if ! eval "$install_cmd"; then
            warn "pipx install failed, trying pip fallback..."
            return 1  # Signal to try pip fallback
        fi

        # Install prisma in litellm venv for auth handling
        if [[ -d "$HOME/.local/pipx/venvs/litellm" ]]; then
            info "Installing prisma..."
            "$HOME/.local/pipx/venvs/litellm/bin/python3" -m pip install prisma 2>/dev/null || true
        fi
    fi

    return 0
}
