#!/bin/bash
set -euo pipefail

source ./utils.sh
source ./bin/config_cask_list.sh
source ./bin/config_cmd_tool_list.sh
source ./bin/config_languagetool_list.sh

########################################base#######################################

check_installed_apps() {
    local installed_apps=()

    for app in "${@}"; do
        if ! brew list | grep -q "$app"; then
            installed_apps+=("$app")
        fi
    done

    if [ ${#installed_apps[@]} -gt 0 ]; then
        echo "${installed_apps[@]}"
    fi
}


check_installed_tool() {
    local installed_tool_list=()

    for tool_name in "$@"; do
        if ! command_exists "${tool_name}"; then
            installed_tool_list+=("$tool_name")
        fi
    done

    if [ ${#installed_tool_list[@]} -gt 0 ]; then
        # echo "Not installed app list: ${installed_tool_list[*]}"
        echo "${installed_tool_list[@]}"
    fi
}

install_cask_list() {
    local app_list=("$@")

    not_installed_app_list=$(check_installed_apps "${app_list[@]}")
    echo "Not installed apps: $not_installed_app_list"
    if [ -n "$not_installed_app_list" ]; then
        for app_name in $not_installed_app_list; do
            echo "🍗 Start to install the app: ${app_name}"
            brew install --cask "${app_name}"
            echo "🎉 Successfully install the app: ${app_name}"
        done
    else
        echo "🎉 All apps are installed already"
    fi
}

install_languagetools() {
    local requested_tools=("${@}")
    local to_install=()

    if ! command_exists "mise"; then
        echo "mise not found, installing mise first..."
        if command -v brew >/dev/null 2>&1; then
            brew install mise
        else
            echo "Homebrew not found. Installing Homebrew first..."
            install_homebrew
            brew install mise
        fi
    fi

    for t in "${requested_tools[@]}"; do
        if command_exists "${t}"; then
            echo "✅ ${t} is already installed; skipping"
        else
            to_install+=("${t}")
        fi
    done

    if [ ${#to_install[@]} -eq 0 ]; then
        echo "🎉 All requested language tools are already installed"
        return 0
    fi

    echo "Installing language tools via mise: ${to_install[*]}"
    mise install "${to_install[@]}"
    echo "🎉 Successfully installed: ${to_install[*]}"
}

install_tool_list() {
    local tool_list="$*"
    not_installed_tool_list=$(check_installed_tool "${tool_list[@]}")
    echo "Not installed tools: $not_installed_tool_list"
    if [ -n "$not_installed_tool_list" ]; then
        for tool_name in $not_installed_tool_list; do
            echo "🍗 Start to install the tool: ${tool_name}"
            brew install "${tool_name}"
            echo "🎉 Successfully install the tool: ${tool_name}"
        done
    else
        echo "🎉 Successfully installed all tools"
    fi
}

install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew already installed at: $(command -v brew)"
        BREW_BIN="$(command -v brew)"
    else
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ -x "/opt/homebrew/bin/brew" ]; then
            BREW_BIN="/opt/homebrew/bin/brew"
        elif [ -x "/usr/local/bin/brew" ]; then
            BREW_BIN="/usr/local/bin/brew"
        else
            BREW_BIN="$(command -v brew || true)"
        fi
    fi

    if [ -n "${BREW_BIN:-}" ]; then
        if ! grep -Fq "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
            echo "Adding Homebrew shellenv to ~/.zprofile"
            (echo; echo "eval \"$(${BREW_BIN} shellenv)\"") >> "$HOME/.zprofile"
        fi

        eval "$("${BREW_BIN}" shellenv)"
    else
        echo "Warning: brew binary not found after attempted install. You may need to add Homebrew to PATH manually."
    fi
}

install_zsh() {
    if ! command -v zsh >/dev/null 2>&1; then
        echo "zsh not found. Installing zsh via Homebrew..."
        if ! command -v brew >/dev/null 2>&1; then
            echo "brew not found. Installing Homebrew first..."
            install_homebrew
        fi
        brew install zsh || true
    else
        echo "zsh is already installed at: $(command -v zsh)"
    fi

    # Default OH_MY_ZSH directory
    ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"

    if [ -d "$ZSH_DIR" ]; then
        echo "Oh My Zsh already installed at $ZSH_DIR, skipping installer"
    else
        echo "Installing Oh My Zsh (non-interactive, will not change shell)..."
        # Disable changing shell and running zsh after install
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-${ZSH_DIR}/custom}"

    # Clone plugins only if they don't already exist
    if [ ! -d "${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions" ]; then
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions"
    else
        echo "zsh-autosuggestions already present"
    fi

    if [ ! -d "${ZSH_CUSTOM_DIR}/plugins/zsh-syntax-highlighting" ]; then
        git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM_DIR}/plugins/zsh-syntax-highlighting"
    else
        echo "zsh-syntax-highlighting already present"
    fi

    if [ ! -d "${ZSH_CUSTOM_DIR}/plugins/zsh-completions" ]; then
        git clone --depth 1 https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM_DIR}/plugins/zsh-completions"
    else
        echo "zsh-completions already present"
    fi
}


install_infra() {
    echo "🍗 Start to install infra..."
    install_homebrew;
    # install_zsh;
    echo "🎉 Successfully installed infra..."
}

########################################base#######################################

#######################################show todo#######################################
show_todo() {
  echo "I think you have installed some necessary softwares on your laptop now. But there are some things need to be done on your side.

  echo "Execute the below command to config the fish."
  echo "chsh -s '$(which fish)'"
🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉
🎉        Have a good journey!                 🎉
🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉
  "
}
#######################################show todo#######################################

install_infra;

install_cask_list "${cast_list[@]}";

install_tool_list "${tool_list[@]}";

install_languagetools "${languagetool_list[@]}";

show_todo;
