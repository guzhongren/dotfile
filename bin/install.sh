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
        if ! which "${tool_name}" &> /dev/null; then
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

install_cloudflare_cert() {
    echo "🍗 Start to install cloudflare cert"
    local cert_path="$HOME/.config/.cloudflare"
    if [ ! -e "${cert_path}" ]; then
        sudo mkdir -p "${cert_path}"
    fi
    sudo curl -o "${cert_path}/Cloudflare_CA.crt" https://developers.cloudflare.com/cloudflare-one/static/Cloudflare_CA.crt
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "${cert_path}/Cloudflare_CA.crt"

    sudo curl -o "${cert_path}/Cloudflare_CA.pem" https://developers.cloudflare.com/cloudflare-one/static/Cloudflare_CA.pem
    (echo | sudo tee -a /etc/ssl/cert.pem) < "${cert_path}/Cloudflare_CA.pem"

    echo "🎉 Successfully installed cloudflare cert"
}


install_homebrew() {
    if ! which "brew" &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

install_zsh() {
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
}

install_infra() {
    echo "🍗 Start to install infra..."
    install_homebrew;
    install_zsh;
    install_cloudflare_cert;
    echo "🎉 Successfully installed infra..."
}

########################################base#######################################
########################################asdf#######################################

install_asdf_dependencies() {
    echo "🍗 Start to install asdf dependencies..."

    if ! which "node" &> /dev/null; then
        asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
        asdf install nodejs 16.13.2
        asdf global nodejs 16.13.2
        asdf shim-versions node
    fi


    if ! which "java" &> /dev/null; then
        asdf plugin-add java https://github.com/halcyon/asdf-java.git
        asdf install java openjdk-11
        asdf global java openjdk-11
    fi

    if ! which "python" &> /dev/null; then
        asdf plugin-add python
        asdf install python 2.7.18
        asdf global python 2.7.18
    fi


    echo "🎉 All asdf dependencies are installed"
}

#######################################asdf#######################################
#######################################zsh#######################################
config_zsh() {
cat << 'EOF' > "$HOME/.zshrc"
    export ZSH="$HOME/.oh-my-zsh"

    ZSH_THEME="robbyrussell"

    plugins=(git)

    source "$ZSH/oh-my-zsh.sh"

    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_INSTALL_CLEANUP=false
    export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
    export HOMEBREW_BREW_GIT_REMOTE=https://mirrors.aliyun.com/homebrew/brew.git
    export HOMEBREW_CORE_GIT_REMOTE=https://mirrors.aliyun.com/homebrew/homebrew-core.git

    export GPG_TTY=$(tty)
    . /opt/homebrew/opt/asdf/libexec/asdf.sh
    export PATH=$PATH:$HOME/.asdf/shims
    PATH=$(pyenv root)/shims:$PATH

    #JAVA_HOME
    . "$HOME/.asdf/plugins/java/set-java-home.zsh"

    eval "$(direnv hook zsh)"
    # enable to download node-pre-gyp package
    export NODE_TLS_REJECT_UNAUTHORIZED=0
EOF
}


#######################################zsh#######################################
#######################################show todo#######################################
show_todo() {
  echo "I think you have installed some necessary softwares on your laptop now. But there are some things need to be done on your side.


  🟢 Apply access to the below platform's account from your lead(OA/TL/PM)
    🟢 Techpass(https://docs.developer.tech.gov.sg/)
    🟢 Techpass(https://docs.developer.tech.gov.sg/)
    🟢 ServiceDesk(https://servicedesk.hpb.gov.sg/)

🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉
🎉        Have a good journey in HPB project!           🎉
🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉
  "
}
#######################################show todo#######################################

cast_list=(
    "raycast"
    "insomnia"
    "flameshot"
    "tencent-lemon"
    "podman-desktop"
    "logseq"
    "itsycal"
    "dbeaver-community"
    "warp"
    "microsoft-azure-storage-explorer"
    "drawio"
    "visual-studio-code"
    "intellij-idea"
    "zed"
    "microsoft-teams"
    "microsoft-edge"
    "google-chrome"
    "react-native-debugger"
    "zoom"
    "the-unarchiver"
    "macpass"
)

tool_list=(
    "asdf"
    "podman"
    "wget"
    "curl"
    "pyenv"
    "vim"
    "direnv"
    "gnupg"
    "helm"
    "kubernetes-cli"
    "maven"
    "ruby"
    "tree"
    "watchman"
    "yq"
    "zstd"
)


install_infra;

install_cask_list "${cast_list[@]}";

install_tool_list "${tool_list[@]}";

install_asdf_dependencies;

config_zsh;

show_todo;
