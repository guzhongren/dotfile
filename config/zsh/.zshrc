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


. /opt/homebrew/opt/asdf/libexec/asdf.sh
export PATH=$PATH:$HOME/.asdf/shims
# PATH=$(pyenv root)/shims:$PATH

#JAVA_HOME
# . "$HOME/.asdf/plugins/java/set-java-home.zsh"

# direnv
eval "$(direnv hook zsh)"

# enable to download node-pre-gyp package
export NODE_TLS_REJECT_UNAUTHORIZED=0

# alias docker="podman"
# export PODMAN_LOG_LEVEL=info
# export DOCKER_HOST=unix:///Users/zhongren.gu/.local/share/containers/podman/machine/podman.sock


# asdf
. $(brew --prefix asdf)/libexec/asdf.sh
# alias docker-compose="podman-compose"

# SSH config
# Start the SSH agent if it's not already running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
fi

# Add the SSH key to the agent
# ssh-add ~/.ssh/hawcroft_bitbucket_id_ed25519
# End SSH config
