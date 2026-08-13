#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/utils.sh"

stage_header "finalize — Verification"

check_tool() {
    if command_exists "$1"; then
        log_info "  $1"
    else
        log_warn "  $1 — not found"
    fi
}

check_tool "brew"
check_tool "mise"
check_tool "fish"

if [ -L "$HOME/.agents" ] && [ "$(readlink "$HOME/.agents")" = "${REPO_ROOT}/docs/ai/agents" ]; then
    log_info "  ~/.agents -> ${REPO_ROOT}/docs/ai/agents"
else
    log_warn "  ~/.agents — not linked (run make post-install)"
fi

echo ""
show_todo
