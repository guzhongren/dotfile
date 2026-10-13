#!/bin/zsh

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"
export ZSH_DISABLE_COMPFIX=true

ZSH_THEME="robbyrussell"
HIST_STAMPS="mm/dd/yyyy"

plugins=(
  git
  z
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# Aliases
alias glol="git log --oneline --decorate --graph --date=local --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset %C(white)%cd%Creset'"
alias k='kubectl'
alias ls='eza --icons'
alias ll='eza -l --icons'
alias rg='rg --hidden --glob "!.git"'
alias cat='bat --paging=never'
alias find='fd'

export EDITOR=vim
export VISUAL=vim
export GPG_TTY="$(tty)"

# Homebrew
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.cernet.edu.cn/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.cernet.edu.cn/homebrew/homebrew-core.git"
export HOMEBREW_INSTALL_FROM_API=1
export HOMEBREW_NO_INSTALL_CLEANUP=
export HOMEBREW_NO_AUTO_UPDATE=true

# Docker / Testcontainers
export DOCKER_HOST=unix:///var/run/docker.sock
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export TESTCONTAINERS_HOST_OVERRIDE=host.docker.internal
export TESTCONTAINERS_RYUK_DISABLED=true

# SSH agent
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  eval "$(ssh-agent -s)"
fi

# Tool initialization
eval "$(direnv hook zsh)"
eval "$(mise activate zsh)"
source <(fzf --zsh)

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Paths
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:/opt/homebrew/opt/openjdk/bin:$HOME/.local/bin:$HOME/01.projects/01.repos/kubectl/bin:$PATH"
export KUBECONFIG="$HOME/.kube/paas.yaml:$HOME/.kube/config"

eval "$(starship init zsh)"
