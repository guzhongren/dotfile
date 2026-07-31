#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/utils.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../bin/config_cask_list.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../bin/config_cmd_tool_list.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../bin/config_languagetool_list.sh"

ensure_brew_env

stage_header "Software Installation"


install_ai_tools() {
  if ! command_exists "codegraph"; then
    curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
  fi

  if ! command_exists "graphify"; then
    uv tool install graphifyy
    export PATH="$HOME/.local/bin:$PATH"
    graphify install
  fi
}

echo ""
echo "--- Installing GUI apps (casks) ---"
# shellcheck disable=SC2154
install_cask_list "${cast_list[@]}"

echo ""
echo "--- Installing CLI tools ---"
# shellcheck disable=SC2154
install_tool_list "${tool_list[@]}"

echo ""
echo "--- Installing language tools (mise) ---"
# shellcheck disable=SC2154
install_languagetools "${languagetool_list[@]}"

echo ""
echo "--- Installing language tools (mise) ---"
install_ai_tools

stage_footer "install"
