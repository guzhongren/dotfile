#!/usr/bin/env bash
set -euo pipefail

function command_exists() {
  if [ $# -lt 1 ]; then
    return 1
  fi

  if command -v "$1" >/dev/null 2>&1; then
    if [ "${VERBOSE:-false}" = "true" ]; then
      echo "🚀 ${1} has installed!"
    fi
    return 0
  else
    if [ "${VERBOSE:-false}" = "true" ]; then
      echo "⚠️ Command: ${1} has not installed!"
    fi
    return 1
  fi
}

function install() {
  command_exists "${1}"
  checked_result=$?
  echo "${checked_result}"
  if [ ${checked_result} != '0' ]; then
    echo 'Start to install' "${1}."
    brew install "${1}"
    echo 'Successfully installed' "${1}!"
  fi
}


function install_cask() {
  command_exists "${1}"
  if ! command_exists "${1}"; then
    echo "Start to install ${1}."
    brew install --cask "$1"
    echo "🚀 Successfully installed ${1}!"
  fi
}


check_folder_exist_or_create() {
  local folder_name="$1"
  if [ ! -d "${folder_name}" ];then
    mkdir -p "$folder_name"
  else
    echo "💡 Folder: ${folder_name} is existing!"
  fi
  echo "🚀 Successfully created ${folder_name}!"
}

todo() {
  echo "⭕⭕⭕⭕⭕⭕⭕⭕⭕⭕==Todo==⭕⭕⭕⭕⭕⭕⭕⭕⭕⭕"
  echo "${1}"
  echo "⭕⭕⭕⭕⭕⭕⭕⭕⭕⭕==Todo==⭕⭕⭕⭕⭕⭕⭕⭕⭕⭕"
}

ensure_brew_env() {
    if command -v brew >/dev/null 2>&1; then
        eval "$(brew shellenv)"
        return 0
    fi

    for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brew_path" ]; then
            eval "$("$brew_path" shellenv)"
            return 0
        fi
    done
}

check_installed_apps() {
    local installed_apps=()
    local brew_casks
    brew_casks=$(brew list --cask 2>/dev/null)

    for app in "${@}"; do
        if ! echo "$brew_casks" | grep -q "$app"; then
            installed_apps+=("$app")
        fi
    done

    if [ ${#installed_apps[@]} -gt 0 ]; then
        echo "${installed_apps[@]}"
    fi
}


check_installed_tool() {
    local installed_tool_list=()
    local brew_packages
    brew_packages=$(brew list 2>/dev/null)

    for tool_name in "$@"; do
        if ! echo "$brew_packages" | grep -q "${tool_name}"; then
            installed_tool_list+=("$tool_name")
        fi
    done

    if [ ${#installed_tool_list[@]} -gt 0 ]; then
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
            echo "Homebrew not found. Run pre-install stage first."
            return 1
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
    mise use -g "${to_install[@]}"
    echo "🎉 Successfully installed: ${to_install[*]}"
}

install_tool_list() {
    not_installed_tool_list=$(check_installed_tool "$@")
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

show_todo() {
  cat <<EOF
I think you have installed some necessary softwares on your laptop now. But there are some things need to be done on your side.

Import your GPG private/public key via gpg --import private/public.key

🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉
🎉            Restart your termial to use config!             🎉
🎉                  Have a good journey!                      🎉
🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉
EOF
}
