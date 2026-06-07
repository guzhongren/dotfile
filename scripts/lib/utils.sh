#!/usr/bin/env bash
set -euo pipefail

# ── Logging ──────────────────────────────────────────────

log_info()    { echo "✅ $1"; }
log_install() { echo "🍗 $1"; }
log_success() { echo "🎉 $1"; }
log_warn()    { echo "⚠️  $1"; }

# ── Stage helpers ────────────────────────────────────────

stage_header() {
    echo "============================================"
    echo " $1"
    echo "============================================"
}

stage_footer() {
    echo "============================================"
    echo " $1 complete"
    echo "============================================"
}

# ── Command checks ───────────────────────────────────────

command_exists() {
    if [ $# -lt 1 ]; then
        return 1
    fi

    if command -v "$1" >/dev/null 2>&1; then
        if [ "${VERBOSE:-false}" = "true" ]; then
            log_info "${1} has installed!"
        fi
        return 0
    else
        if [ "${VERBOSE:-false}" = "true" ]; then
            log_warn "Command: ${1} has not installed!"
        fi
        return 1
    fi
}

# ── Filesystem ───────────────────────────────────────────

check_folder_exist_or_create() {
    local folder_name="$1"
    if [ -d "${folder_name}" ]; then
        echo "💡 Folder: ${folder_name} is existing!"
    else
        mkdir -p "$folder_name"
        log_success "Successfully created ${folder_name}!"
    fi
}

link_dotfile() {
    local src="$1"
    local dest="$2"
    local dir
    dir="$(dirname "$dest")"
    check_folder_exist_or_create "$dir"
    ln -sf "$src" "$dest"
    log_info "$(basename "$dest") linked"
}

# ── Notifications ────────────────────────────────────────

todo() {
    echo "⭕⭕⭕⭕⭕⭕⭕⭕⭕⭕==Todo==⭕⭕⭕⭕⭕⭕⭕⭕⭕⭕"
    echo "${1}"
    echo "⭕⭕⭕⭕⭕⭕⭕⭕⭕⭕==Todo==⭕⭕⭕⭕⭕⭕⭕⭕⭕⭕"
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

# ── Brew environment ─────────────────────────────────────

ensure_brew_env() {
    if command -v brew >/dev/null 2>&1; then
        eval "$(brew shellenv)"
        BREW_BIN="$(command -v brew)"
        export BREW_BIN
        return 0
    fi

    for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brew_path" ]; then
            eval "$("$brew_path" shellenv)"
            export BREW_BIN="$brew_path"
            return 0
        fi
    done
}

# ── Brew package lists ──────────────────────────────────

_brew_list_installed() {
    local type="$1"  # "cask" or "formula"
    shift
    local items=("$@")

    local installed
    if [ "$type" = "cask" ]; then
        installed=$(brew list --cask 2>/dev/null)
    else
        installed=$(brew list 2>/dev/null)
    fi

    local missing=()
    for item in "${items[@]}"; do
        if ! echo "$installed" | grep -qxF "$item"; then
            missing+=("$item")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "${missing[@]}"
    fi
}

check_installed_apps() {
    _brew_list_installed "cask" "$@"
}

check_installed_tool() {
    _brew_list_installed "formula" "$@"
}

# ── Bulk installers ──────────────────────────────────────

install_cask_list() {
    local missing
    missing=$(check_installed_apps "$@")
    echo "Not installed apps: $missing"
    if [ -n "$missing" ]; then
        for app_name in $missing; do
            log_install "Start to install the app: ${app_name}"
            brew install --cask "${app_name}"
            log_success "Successfully install the app: ${app_name}"
        done
    else
        log_success "All apps are installed already"
    fi
}

install_tool_list() {
    local missing
    missing=$(check_installed_tool "$@")
    echo "Not installed tools: $missing"
    if [ -n "$missing" ]; then
        # brew can batch-install multiple packages
        for tool_name in $missing; do
            log_install "Start to install the tool: ${tool_name}"
            brew install "${tool_name}"
            log_success "Successfully install the tool: ${tool_name}"
        done
    else
        log_success "Successfully installed all tools"
    fi
}

install_languagetools() {
    local requested_tools=("${@}")

    if ! command_exists "mise"; then
        echo "mise not found, installing mise first..."
        if command -v brew >/dev/null 2>&1; then
            brew install mise
        else
            echo "Homebrew not found. Run pre-install stage first."
            return 1
        fi
    fi

    mkdir -p "$HOME/.config/mise"

    # Check which tools are already installed via mise
    local missing=()
    for tool in "${requested_tools[@]}"; do
        # Extract the actual command name (strip backend prefix like "npm:")
        local cmd_name="${tool#*:}"
        if command_exists "$cmd_name"; then
            log_info "Already installed: ${tool}"
        else
            missing+=("$tool")
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        log_success "All language tools are already installed"
        return 0
    fi

    echo "Installing language tools via mise: ${missing[*]}"
    mise install "${missing[@]}"
    mise use -g "${requested_tools[@]}"
    log_success "Successfully installed: ${missing[*]}"
}

# ── ZSH plugins ─────────────────────────────────────────

install_omz_plugin() {
    local name="$1"
    local repo_url="$2"
    local dir="${ZSH_CUSTOM_DIR:?}/${name}"

    if [ ! -d "$dir" ]; then
        git clone --depth 1 "$repo_url" "$dir"
        log_info "${name} installed"
    else
        log_info "${name} already present"
    fi
}
