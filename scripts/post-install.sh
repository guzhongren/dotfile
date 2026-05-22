#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

ensure_brew_env

echo "============================================"
echo " Shell & Config"
echo "============================================"

# --- Symlinks ---
echo ""
echo "--- Creating symlinks ---"

check_folder_exist_or_create "$HOME/.gnupg"
ln -sf "${REPO_ROOT}/config/.gnupg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"
echo "✅ gpg-agent.conf linked"

check_folder_exist_or_create "$HOME/.config/fish"
ln -sf "${REPO_ROOT}/config/fish/config.fish" "$HOME/.config/fish/config.fish"
echo "✅ fish config linked"

check_folder_exist_or_create "$HOME/.config/ghostty"
ln -sf "${REPO_ROOT}/config/ghostty/config" "$HOME/.config/ghostty/config"
echo "✅ ghostty config linked"

ln -sf "${REPO_ROOT}/config/starship/starship.toml" "$HOME/.config/starship.toml"
echo "✅ starship config linked"

# --- GPG ---
echo ""
echo "--- Configuring GPG ---"

chmod 700 ~/.gnupg
chmod 600 ~/.gnupg/*

killall gpg-agent
gpgconf --kill gpg-agent

gpg --list-secret-keys --keyid-format=long || true
git config --global user.signingkey D18AEC180356622D
git config --global commit.gpgSign true
git config --global tag.forceSignAnnotated true

PINENTRY_PROG="$(which pinentry-tty 2>/dev/null || echo "/opt/homebrew/bin/pinentry-tty")"
if ! grep -Fq "pinentry-program" "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
    echo "pinentry-program ${PINENTRY_PROG}" >> "$HOME/.gnupg/gpg-agent.conf"
    echo "✅ pinentry-program added to gpg-agent.conf"
else
    echo "✅ pinentry-program already configured in gpg-agent.conf"
fi
gpgconf --reload gpg-agent 2>/dev/null || true

todo "Need to import those GPG keys: private.key, public.key!"

# --- Oh My Zsh + plugins ---
echo ""
echo "--- Setting up Oh My Zsh ---"

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"

if [ -d "$ZSH_DIR" ]; then
    echo "✅ Oh My Zsh already installed at $ZSH_DIR"
else
    echo "🍗 Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-${ZSH_DIR}/custom}"

if [ ! -d "${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions" ]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions"
    echo "✅ zsh-autosuggestions installed"
else
    echo "✅ zsh-autosuggestions already present"
fi

if [ ! -d "${ZSH_CUSTOM_DIR}/plugins/zsh-syntax-highlighting" ]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM_DIR}/plugins/zsh-syntax-highlighting"
    echo "✅ zsh-syntax-highlighting installed"
else
    echo "✅ zsh-syntax-highlighting already present"
fi

if [ ! -d "${ZSH_CUSTOM_DIR}/plugins/zsh-completions" ]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM_DIR}/plugins/zsh-completions"
    echo "✅ zsh-completions installed"
else
    echo "✅ zsh-completions already present"
fi

# --- Fisher + fish plugins ---
echo ""
echo "--- Setting up Fisher ---"

if command_exists "fish"; then
    if fish -c "type fisher" >/dev/null 2>&1; then
        echo "✅ Fisher already installed"
    else
        echo "🍗 Installing Fisher and plugins..."
        fish -c "
            curl -sL https://git.io/fisher | source
            fisher install jorgebucaran/fisher
            fisher install jethrokuan/z
            fisher install jorgebucaran/autopair.fish
            fisher install PatrickF1/fzf.fish
            fisher install edc/bass
            fisher install jhillyerd/plugin-git
        "
        echo "🎉 Fisher and plugins installed"
    fi
else
    echo "⚠️  fish not found, skipping Fisher setup"
fi

# --- Shell change ---
echo ""
if command_exists "fish"; then
    grep -qxF '/opt/homebrew/bin/fish' /etc/shells || echo '/opt/homebrew/bin/fish' | sudo tee -a /etc/shells > /dev/null
    CURRENT_SHELL="$(basename "$SHELL")"
    FISH_PATH="$(which fish)"
    if [ "$CURRENT_SHELL" = "fish" ]; then
        echo "✅ Shell is already fish"
    else
        echo "🍗 Changing default shell to fish..."
        if [ -n "${CI:-}" ]; then
            sudo chsh -s "$FISH_PATH"
        else
            chsh -s "$FISH_PATH"
        fi
        echo "🎉 Shell changed to fish"
    fi
fi

# --- mise completion ---
echo ""
if command_exists "mise"; then
    mise completion fish >/dev/null 2>&1 || true
    echo "✅ mise fish completion generated"
fi

echo "============================================"
echo " post-install complete"
echo "============================================"
