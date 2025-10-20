#!/bin/bash
set -euo pipefail

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

command_exists() {
    if [ $# -lt 1 ]; then
        return 1
    fi
    command -v "$1" >/dev/null 2>&1
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
    install_zsh;
    echo "🎉 Successfully installed infra..."
}
 install_rime_ice() {
    app_name="Rime_ICE"
    echo "🍗 Start to install ${app_name}..."
    git clone https://github.com/iDvel/rime-ice.git ~/Library/RimeRime --depth 1
    echo "🎉 Successfully installed ${app_name}..."
 }

########################################base#######################################
########################################asdf#######################################

install_asdf_dependencies() {
    echo "🍗 Start to install asdf dependencies..."



    echo "🎉 All asdf dependencies are installed"
}

#######################################asdf#######################################
#######################################zsh#######################################
config_zsh() {
cat << 'EOF' > "$HOME/.zshrc"
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
        source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi

    export ZSH="$HOME/.oh-my-zsh"

    ZSH_THEME="robbyrussell"

    HIST_STAMPS="mm/dd/yyyy"

    ZSH_CUSTOM=$ZSH/custom

    plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    )

    source $ZSH/oh-my-zsh.sh


    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    export CARGO_INCREMENTAL=0
    export PATH="$HOME/.deno/bin:$PATH"
    fpath=(~/.zsh $fpath)
    autoload -Uz compinit
    compinit -u

    alias ls='lsd'
    export GPG_TTY=$(tty)

    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.aliyun.com/homberew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.aliyun.com/homebrew/homebrew-core.git"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.aliyun.com/homebrew/homebrew-bottles"
    export HOMEBREW_NO_INSTALL_CLEANUP=false
    export HOMEBREW_NO_AUTO_UPDATE=true

    export ZSH_DISABLE_COMPFIX=true

    alias daily="cd '~/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents'"

    alias glol="git log --oneline --decorate --graph --date=local --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset %C(white)%cd%Creset'"



    # direnv
    eval "$(direnv hook zsh)"

    # enable to download node-pre-gyp package
    export NODE_TLS_REJECT_UNAUTHORIZED=0

    # alias docker="podman"
    # export PODMAN_LOG_LEVEL=info
    # export DOCKER_HOST=unix:///Users/zhongren.gu/.local/share/containers/podman/machine/podman.sock


    # alias docker-compose="podman-compose"

    # pnpm
    export PNPM_HOME="~/Library/pnpm"
    case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
    # pnpm end

    # SSH config
    # Start the SSH agent if it's not already running
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        eval "$(ssh-agent -s)"
    fi

    # Add the SSH key to the agent
    # ssh-add ~/.ssh/hawcroft_bitbucket_id_ed25519
    # End SSH config
EOF
}


#######################################zsh#######################################
#######################################show todo#######################################
show_todo() {
  echo "I think you have installed some necessary softwares on your laptop now. But there are some things need to be done on your side.

🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉
🎉        Have a good journey in HPB project!           🎉
🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉
  "
}
#######################################show todo#######################################

cast_list=(
    # "raycast"
    # "flameshot"
    "tencent-lemon"
    "logseq"
    "itsycal"
    "dbeaver-community"
    "warp"
    "drawio"
    "visual-studio-code"
    "zed"
    # "microsoft-edge"
    "google-chrome"
    "zoom"
    "the-unarchiver"
    "languagetool"
)

tool_list=(
    "mise"
    "colima"
    "wget"
    "curl"
    "vim"
    "direnv"
    "gnupg"
    "kubernetes-cli"
    "tree"
    "watchman"
    "yq"
    "lsd"
    "docker"
    "docker-compose"
)


install_infra;

install_cask_list "${cast_list[@]}";

install_tool_list "${tool_list[@]}";

install_asdf_dependencies;

config_zsh;

install_rime_ice;

show_todo;
