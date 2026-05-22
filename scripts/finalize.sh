#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

echo ""
echo "--- Verifying installed tools ---"

check_tool() {
    if command_exists "$1"; then
        echo "  ✅ $1"
    else
        echo "  ❌ $1 — not found"
    fi
}

check_tool "brew"
check_tool "mise"
check_tool "fish"

echo ""
show_todo
