#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

echo "============================================"
echo " pre-install — Package Managers"
echo "============================================"

# Homebrew
if command -v brew >/dev/null 2>&1; then
    echo "✅ Homebrew already installed at: $(command -v brew)"
    BREW_BIN="$(command -v brew)"
else
    echo "🍗 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -x "/opt/homebrew/bin/brew" ]; then
        BREW_BIN="/opt/homebrew/bin/brew"
    elif [ -x "/usr/local/bin/brew" ]; then
        BREW_BIN="/usr/local/bin/brew"
    else
        BREW_BIN="$(command -v brew || true)"
    fi
fi

# Add brew shellenv to ~/.zprofile
if [ -n "${BREW_BIN:-}" ]; then
    if ! grep -Fq "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
        echo "Adding Homebrew shellenv to ~/.zprofile"
        printf '\neval "$(%s shellenv)"\n' "$BREW_BIN" >> "$HOME/.zprofile"
    fi
    eval "$("${BREW_BIN}" shellenv)"
else
    echo "WARNING: brew binary not found after install. You may need to add Homebrew to PATH manually."
fi

# mise
if command_exists "mise"; then
    echo "✅ mise already installed"
else
    echo "🍗 Installing mise via Homebrew..."
    brew install mise
    echo "🎉 mise installed"
fi

echo "============================================"
echo " pre-install complete"
echo "============================================"
