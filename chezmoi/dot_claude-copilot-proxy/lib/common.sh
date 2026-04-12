#!/usr/bin/env bash
# lib/common.sh - Shared utilities: colors, logging, prompts, constants

# =============================================================================
# Constants
# =============================================================================

KEYCHAIN_SERVICE="${KEYCHAIN_SERVICE:-litellm-copilot-token}"
LAUNCHD_LABEL="${LAUNCHD_LABEL:-com.claude-copilot-proxy}"
SYSTEMD_SERVICE="${SYSTEMD_SERVICE:-claude-copilot-proxy}"
PROXY_PORT="${PROXY_PORT:-4000}"

# =============================================================================
# Colors
# =============================================================================

# Colors (with fallback for non-color terminals)
if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

# Logging functions
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
fatal() {
    error "$*"
    exit 1
}

# Interactive prompts
prompt_yes_no() {
    local prompt="$1"
    local default="${2:-y}"

    if [[ "${QUIET:-false}" == "true" ]]; then
        [[ "$default" == "y" ]]
        return
    fi

    local yn_hint="[Y/n]"
    [[ "$default" == "n" ]] && yn_hint="[y/N]"

    read -r -p "$prompt $yn_hint: " response
    response="${response:-$default}"
    [[ "$response" =~ ^[Yy] ]]
}

prompt_input() {
    local prompt="$1"
    local var_name="$2"
    local default="${3:-}"

    if [[ "${QUIET:-false}" == "true" ]] && [[ -n "$default" ]]; then
        eval "$var_name='$default'"
        return
    fi

    local hint=""
    [[ -n "$default" ]] && hint=" [$default]"

    read -r -p "$prompt$hint: " response
    response="${response:-$default}"
    eval "$var_name='$response'"
}

# Utility functions
command_exists() {
    command -v "$1" &>/dev/null
}
