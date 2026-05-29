#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

stage_header "pre-install — Package Managers"

ensure_brew_env
brew update

# Add brew shellenv to ~/.zprofile for future shells
if [ -n "${BREW_BIN:-}" ] && ! grep -Fq "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
    echo "Adding Homebrew shellenv to ~/.zprofile"
    printf '\neval "$(%s shellenv)"\n' "$BREW_BIN" >> "$HOME/.zprofile"
fi

if command_exists "mise"; then
    log_info "mise already installed"
else
    log_install "Installing mise via Homebrew..."
    brew install mise
    log_success "mise installed"
fi

stage_footer "pre-install"
