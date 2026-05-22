#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

echo "============================================"
echo " pre-config — System Checks"
echo "============================================"

# OS detection
if [[ "$(uname)" != "Darwin" ]]; then
    echo "ERROR: This setup is designed for macOS only. Detected: $(uname)"
    exit 1
fi
echo "✅ macOS detected: $(sw_vers -productVersion)"

# Xcode CLI tools
if xcode-select -p >/dev/null 2>&1; then
    echo "✅ Xcode CLI tools already installed at: $(xcode-select -p)"
else
    echo "⚠️  Xcode CLI tools not found. Installing..."
    xcode-select --install
    echo "👉 Follow the GUI prompt to install Xcode CLI tools, then re-run this stage."
    exit 1
fi

# Git identity
git config --global user.email "guzhongren@live.cn"
git config --global user.name "guzhongren"
echo "✅ Git identity configured: guzhongren <guzhongren@live.cn>"

# SSH key check
if [ ! -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
    todo "No SSH key found (~/.ssh/id_ed25519 or ~/.ssh/id_rsa). Generate one with: ssh-keygen -t ed25519 -C 'guzhongren@live.cn'"
fi

echo "============================================"
echo " pre-config complete"
echo "============================================"
