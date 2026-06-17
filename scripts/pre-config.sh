#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/utils.sh"
# shellcheck disable=SC1091
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

config_git_infra() {
  git config --global user.email "$GIT_USER_EMAIL"
  git config --global user.name "$GIT_USER_NAME"
  log_info "Git identity configured: ${GIT_USER_NAME} <${GIT_USER_EMAIL}>"

  # Git config globally
  link_dotfile "${REPO_ROOT}/config/git/.gitconfig" "$HOME/.gitconfig"
  link_dotfile "${REPO_ROOT}/config/git/.gitconfig-client" "$HOME/.gitconfig-client"
  link_dotfile "${REPO_ROOT}/config/git/.gitconfig-personal" "$HOME/.gitconfig-personal"
  link_dotfile "${REPO_ROOT}/config/git/.gitignore-global" "$HOME/.gitignore-global"
}

show_ssh_todo() {
  if [ ! -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
    todo "No SSH key found (~/.ssh/id_ed25519 or ~/.ssh/id_rsa). Generate one with: ssh-keygen -t ed25519 -C '${GIT_USER_EMAIL}'"
  fi
}

create_base_folders() {
  check_folder_exist_or_create "$HOME/01.clients"
  check_folder_exist_or_create "$HOME/02.personal"
}

create_base_folders;
show_ssh_todo;
config_git_infra;

stage_footer "pre-config"
