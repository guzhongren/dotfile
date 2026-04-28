if status is-interactive
    # Commands to run in interactive sessions can go here
    # Git 插件配置
    set -g plugin_git_disabled_aliases gst gsta

    # 自定义别名
    alias gpr "git pull --rebase"
    alias gcmsg "git commit -m"

    # 彩色输出
    set -g fish_color_git_clean green
    set -g fish_color_git_staged yellow
    set -g fish_color_git_dirty red
end

# Aliases
alias ls lsd
alias daily "cd '$HOME/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents'"
alias glol "git log --oneline --decorate --graph --date=local --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset %C(white)%cd%Creset'"
alias k kubectl

# GPG
set -gx GPG_TTY (tty)

# Homebrew
set -gx HOMEBREW_NO_INSTALL_CLEANUP ""
set -gx HOMEBREW_NO_AUTO_UPDATE true

# TestContainers / Docker
set -gx DOCKER_HOST unix:///var/run/docker.sock
set -gx TESTCONTAINERS_HOST_OVERRIDE host.docker.internal
set -gx TESTCONTAINERS_RYUK_DISABLED true

# # SSH agent
# if not pgrep -u $USER ssh-agent > /dev/null
#     eval (ssh-agent -c)
# end

# direnv
direnv hook fish | source

# mise
mise activate fish | source
mise reshim


# Starship prompt
starship init fish | source
