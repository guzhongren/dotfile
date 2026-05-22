#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

echo ""
show_todo
