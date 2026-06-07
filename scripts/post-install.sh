#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/utils.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../bin/config_user.sh"

ensure_brew_env

stage_header "Shell & Config"

# ── Symlinks ───────────────────────

create_syslinks() {
  echo ""
  echo "--- Creating symlinks ---"

  link_dotfile "${REPO_ROOT}/config/.gnupg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"
  link_dotfile "${REPO_ROOT}/config/fish/config.fish" "$HOME/.config/fish/config.fish"
  link_dotfile "${REPO_ROOT}/config/ghostty/config" "$HOME/.config/ghostty/config"
  link_dotfile "${REPO_ROOT}/config/starship/starship.toml" "$HOME/.config/starship.toml"
  link_dotfile "${REPO_ROOT}/config/zed/settings.json" "$HOME/.config/zed/settings.json"
}


# ── GPG ─────────────────────────────

config_gpg() {
  echo ""
  echo "--- Configuring GPG ---"

  chmod 700 ~/.gnupg
  find ~/.gnupg -type f -exec chmod 600 {} + 2>/dev/null || true
  gpgconf --kill gpg-agent 2>/dev/null || true

  gpg --list-secret-keys --keyid-format=long || true
  git config --global user.signingkey "$GPG_SIGNING_KEY"
  git config --global commit.gpgSign true
  git config --global tag.forceSignAnnotated true

  PINENTRY_PROG="$(which pinentry-tty 2>/dev/null || echo "/opt/homebrew/bin/pinentry-tty")"
  if ! grep -Fq "pinentry-program" "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
      echo "pinentry-program ${PINENTRY_PROG}" >> "$HOME/.gnupg/gpg-agent.conf"
      log_info "pinentry-program added to gpg-agent.conf"
  else
      log_info "pinentry-program already configured in gpg-agent.conf"
  fi
  gpgconf --reload gpg-agent 2>/dev/null || true

  todo "Need to import those GPG keys: private.key, public.key!"
}

# ── Oh My Zsh ───────────────────────

install_config_zsh() {
  echo ""
  echo "--- Setting up Oh My Zsh ---"

  ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"

  if [ -d "$ZSH_DIR" ]; then
      log_info "Oh My Zsh already installed at $ZSH_DIR"
  else
      log_install "Installing Oh My Zsh..."
      RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  export ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-${ZSH_DIR}/custom}"

  install_omz_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
  install_omz_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
  install_omz_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions"
}


# ── Fisher ──────────────────────────
install_cofig_fish() {
  echo ""
  echo "--- Setting up Fisher ---"

  if command_exists "fish"; then
      if fish -c "type fisher" >/dev/null 2>&1; then
          log_info "Fisher already installed"
      else
          log_install "Installing Fisher and plugins..."
          fish -c "
              curl -sL https://git.io/fisher | source
              fisher install jorgebucaran/fisher jethrokuan/z jorgebucaran/autopair.fish PatrickF1/fzf.fish edc/bass jhillyerd/plugin-git
          "
          log_success "Fisher and plugins installed"
      fi
  else
      log_warn "fish not found, skipping Fisher setup"
  fi



}

shell_change() {
  echo ""
  if command_exists "fish"; then
      grep -qxF '/opt/homebrew/bin/fish' /etc/shells || echo '/opt/homebrew/bin/fish' | sudo tee -a /etc/shells > /dev/null
      CURRENT_SHELL="$(basename "$SHELL")"
      FISH_PATH="$(which fish)"
      if [ "$CURRENT_SHELL" = "fish" ]; then
          log_info "Shell is already fish"
      else
          log_install "Changing default shell to fish..."
          if [ -n "${CI:-}" ]; then
              sudo chsh -s "$FISH_PATH"
          else
              chsh -s "$FISH_PATH"
          fi
          log_success "Shell changed to fish"
      fi
  fi
}

# ── mise completion ────────────────
conig_mise() {
  echo ""
  if command_exists "mise"; then
      mise completion fish >/dev/null 2>&1 || true
      log_info "mise fish completion generated"
  fi
}

config_ai_compresses() {
  mkdir -p ~/.claude
  rtk init -g --auto-patch
  rtk telemetry disable
}

create_syslinks;
config_gpg;
# install_config_zsh;
install_cofig_fish;
shell_change;
conig_mise;
config_ai_compresses;

stage_footer "post-install"
