#!/bin/zsh
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

HIST_STAMPS="mm/dd/yyyy"

ZSH_CUSTOM="$ZSH/custom"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source "$ZSH/oh-my-zsh.sh"

# fpath=(~/.zsh "$fpath")
# autoload -Uz compinit
# compinit -u

alias ls='lsd'
export GPG_TTY
GPG_TTY=$(tty)

# export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.aliyun.com/homberew/brew.git"
#export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.aliyun.com/homebrew/homebrew-core.git"
#export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.aliyun.com/homebrew/homebrew-bottles"
export HOMEBREW_NO_INSTALL_CLEANUP=
export HOMEBREW_NO_AUTO_UPDATE=true

export ZSH_DISABLE_COMPFIX=true

alias daily="cd '~/Library/Mobile\ Documents/iCloud\~com\~logseq\~logseq/Documents'"
alias glol="git log --oneline --decorate --graph --date=local --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset %C(white)%cd%Creset'"

# direnv
eval "$(direnv hook zsh)"

# enable to download node-pre-gyp package
export NODE_TLS_REJECT_UNAUTHORIZED=1

# alias docker="podman"
# export PODMAN_LOG_LEVEL=info
# export DOCKER_HOST=unix:///Users/zhongren.gu/.local/share/containers/podman/machine/podman.sock
# alias docker-compose="podman-compose"

export DOCKER_HOST=unix://${HOME}/.colima/default/docker.sock
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock

# SSH config
# Start the SSH agent if it's not already running
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  eval "$(ssh-agent -s)"
fi

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
eval "$(mise activate zsh)"
alias k="kubectl"
