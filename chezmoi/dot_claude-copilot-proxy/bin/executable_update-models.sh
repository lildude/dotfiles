#!/usr/bin/env bash
# bin/update-models.sh - Fetch available Copilot models, test each one, and update config.yaml
#
# Usage:
#   ./bin/update-models.sh              # Update config.yaml in place
#   ./bin/update-models.sh --dry-run    # Show what would change without modifying files

set -euo pipefail

# Determine script and proxy directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROXY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
export PROXY_DIR

# Source required modules
source "${PROXY_DIR}/lib/common.sh"
source "${PROXY_DIR}/lib/detect.sh"
source "${PROXY_DIR}/lib/token/main.sh"

# Configuration
CONFIG_FILE="$PROXY_DIR/config.yaml"
TODAY=$(date +%Y-%m-%d)

MODELS_API_URL="https://api.githubcopilot.com/models"
CHAT_API_URL="https://api.githubcopilot.com/chat/completions"
RESPONSES_API_URL="https://api.githubcopilot.com/responses"

DRY_RUN=false

# =============================================================================
# Parse Arguments
# =============================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            ;;
        --help|-h)
            echo "Usage: $(basename "$0") [--dry-run]"
            echo ""
            echo "Fetch available models from GitHub Copilot API and update config.yaml"
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would change without modifying files"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# =============================================================================
# Check Dependencies
# =============================================================================

for cmd in jq curl; do
    if ! command_exists "$cmd"; then
        fatal "$cmd is required but not installed"
    fi
done

# =============================================================================
# Get Token (uses shared lib/token/main.sh)
# =============================================================================

# Detect platform first (quiet mode - no output)
detect_platform_quiet

# Ensure platform detection succeeded
if [[ -z "${PLATFORM:-}" ]]; then
    fatal "Unable to detect platform. Cannot retrieve GitHub token."
fi

GITHUB_TOKEN=$(get_token)

if [[ -z "$GITHUB_TOKEN" ]]; then
    fatal "GitHub PAT not found. Run bin/setup.sh first."
fi

# Common headers for Copilot API
CURL_HEADERS=(
    -H "Authorization: Bearer $GITHUB_TOKEN"
    -H "Editor-Version: vscode/1.95.0"
    -H "Editor-Plugin-Version: copilot-chat/0.22.4"
    -H "Copilot-Integration-Id: vscode-chat"
)

# =============================================================================
# Fetch Models
# =============================================================================

info "Fetching models from GitHub Copilot API..."

RESPONSE=$(curl -s -w "\n%{http_code}" "${CURL_HEADERS[@]}" "$MODELS_API_URL")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" != "200" ]]; then
    fatal "API request failed with status $HTTP_CODE: $BODY"
fi

# Filter and extract models
MODELS_JSON=$(echo "$BODY" | jq -c '
    [.data[]
     | select(.model_picker_enabled == true)
     | select(.name | contains("Internal Only") | not)
    ]
    | sort_by(.id)
')

MODEL_COUNT=$(echo "$MODELS_JSON" | jq 'length')
success "Found $MODEL_COUNT available models"
echo

# =============================================================================
# Test Models
# =============================================================================

test_model() {
    local model_id="$1"
    local response http_code body content

    # Use responses API for GPT-5 family, chat completions for others
    if [[ "$model_id" == gpt-5* ]]; then
        response=$(curl -s -w "\n%{http_code}" \
            "${CURL_HEADERS[@]}" \
            -H "Content-Type: application/json" \
            --max-time 60 \
            -d "{\"model\": \"$model_id\", \"input\": [{\"role\": \"user\", \"content\": \"Say hello in one word.\"}], \"reasoning\": {\"effort\": \"low\"}}" \
            "$RESPONSES_API_URL" 2>/dev/null)
    else
        response=$(curl -s -w "\n%{http_code}" \
            "${CURL_HEADERS[@]}" \
            -H "Content-Type: application/json" \
            --max-time 60 \
            -d "{\"model\": \"$model_id\", \"messages\": [{\"role\": \"user\", \"content\": \"Say hello in one word.\"}]}" \
            "$CHAT_API_URL" 2>/dev/null)
    fi

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [[ "$http_code" != "200" ]]; then
        echo "FAIL - HTTP $http_code"
        return 1
    fi

    # Extract content based on response format
    if [[ "$model_id" == gpt-5* ]]; then
        content=$(echo "$body" | jq -r '.output[]? | select(.type == "message") | .content[]? | select(.type == "output_text") | .text' 2>/dev/null | head -c 50)
    else
        content=$(echo "$body" | jq -r '.choices[0].message.content // empty' 2>/dev/null | head -c 50)
    fi

    if [[ -n "$content" ]]; then
        echo "PASS"
        return 0
    else
        echo "FAIL - No content"
        return 1
    fi
}

info "Testing models..."
echo "------------------------------------------------------------"

WORKING_MODELS=()
FAILED_MODELS=()

while IFS= read -r model_id; do
    printf "Testing %s... " "$model_id"
    if test_model "$model_id"; then
        WORKING_MODELS+=("$model_id")
    else
        FAILED_MODELS+=("$model_id")
    fi
done < <(echo "$MODELS_JSON" | jq -r '.[].id')

echo "------------------------------------------------------------"
echo

# =============================================================================
# Summary
# =============================================================================

success "Results: ${#WORKING_MODELS[@]} working, ${#FAILED_MODELS[@]} failed"
echo

if [[ ${#FAILED_MODELS[@]} -gt 0 ]]; then
    warn "Failed models:"
    for model_id in "${FAILED_MODELS[@]}"; do
        echo "  - $model_id"
    done
    echo
fi

if [[ ${#WORKING_MODELS[@]} -eq 0 ]]; then
    fatal "No working models found!"
fi

# =============================================================================
# Generate Config
# =============================================================================

CONFIG_ALIASES=""
for model_id in "${WORKING_MODELS[@]}"; do
    CONFIG_ALIASES+="    \"$model_id\": \"$model_id\""$'\n'
done
CONFIG_ALIASES=${CONFIG_ALIASES%$'\n'}

if $DRY_RUN; then
    echo "=== DRY RUN - No files will be modified ==="
    echo
    echo "--- Supported models for config.yaml ---"
    echo "$CONFIG_ALIASES"
    echo
    echo "--- Date: $TODAY ---"
    exit 0
fi

# =============================================================================
# Update Config File
# =============================================================================

info "Updating $CONFIG_FILE..."

TEMP_FILE=$(mktemp)
IN_SUPPORTED_MODELS=false
SUPPORTED_MODELS_WRITTEN=false

while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == *"# Supported models"* ]]; then
        IN_SUPPORTED_MODELS=true
        printf '%s\n' "$line" >> "$TEMP_FILE"
        if ! $SUPPORTED_MODELS_WRITTEN; then
            printf '%s\n' "$CONFIG_ALIASES" >> "$TEMP_FILE"
            SUPPORTED_MODELS_WRITTEN=true
        fi
    elif $IN_SUPPORTED_MODELS && [[ "$line" == *"# Claude Code compatibility"* ]]; then
        IN_SUPPORTED_MODELS=false
        printf '%s\n' "$line" >> "$TEMP_FILE"
    elif $IN_SUPPORTED_MODELS && [[ "$line" =~ ^[[:space:]]*\" ]]; then
        continue
    else
        printf '%s\n' "$line" >> "$TEMP_FILE"
    fi
done < "$CONFIG_FILE"

mv "$TEMP_FILE" "$CONFIG_FILE"

echo
success "Updated models list ($TODAY)"
echo
echo "Working models (${#WORKING_MODELS[@]}):"
for model_id in "${WORKING_MODELS[@]}"; do
    echo "  $model_id"
done
