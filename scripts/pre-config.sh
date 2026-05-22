#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/../bin/config_user.sh"

stage_header "pre-config — System Checks"

if [[ "$(uname)" != "Darwin" ]]; then
    echo "ERROR: This setup is designed for macOS only. Detected: $(uname)"
    exit 1
fi
log_info "macOS detected: $(sw_vers -productVersion)"

if xcode-select -p >/dev/null 2>&1; then
    log_info "Xcode CLI tools already installed at: $(xcode-select -p)"
else
    log_warn "Xcode CLI tools not found. Installing..."
    xcode-select --install
    echo "👉 Follow the GUI prompt to install Xcode CLI tools, then re-run this stage."
    exit 1
fi

git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"
log_info "Git identity configured: ${GIT_USER_NAME} <${GIT_USER_EMAIL}>"

if [ ! -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
    todo "No SSH key found (~/.ssh/id_ed25519 or ~/.ssh/id_rsa). Generate one with: ssh-keygen -t ed25519 -C '${GIT_USER_EMAIL}'"
fi

stage_footer "pre-config"
