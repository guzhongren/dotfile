#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/../bin/config_cask_list.sh"
source "${SCRIPT_DIR}/../bin/config_cmd_tool_list.sh"
source "${SCRIPT_DIR}/../bin/config_languagetool_list.sh"

ensure_brew_env

echo "============================================"
echo " Software Installation"
echo "============================================"

echo ""
echo "--- Installing GUI apps (casks) ---"
install_cask_list "${cast_list[@]}"

echo ""
echo "--- Installing CLI tools ---"
install_tool_list "${tool_list[@]}"

echo ""
echo "--- Installing language tools (mise) ---"
install_languagetools "${languagetool_list[@]}"

echo "============================================"
echo " install complete"
echo "============================================"
