# dotfile

macOS 开发环境一键配置，通过 `make all` 按阶段完成系统设置。

> Simply, Efficient

## 快速开始

```shell
git clone https://github.com/guzhongren/dotfile.git ~/.dotfile
cd ~/.dotfile
make all
```

## 阶段说明

Setup 分为 5 个阶段，每个阶段可独立运行且幂等（可安全重复执行）：

| 阶段 | 命令 | 职责 |
|------|------|------|
| pre-config | `make pre-config` | 系统检测（macOS / Xcode CLI）、Git 身份配置、SSH key 检查 |
| pre-install | `make pre-install` | 包管理器（Homebrew、mise） |
| install | `make install` | 软件安装（brew casks、brew CLI tools、mise language tools） |
| post-install | `make post-install` | 软链 dotfiles、GPG 签名、Oh My Zsh 插件、Fisher 插件、默认 Shell 切换 |
| finalize | `make finalize` | 验证已安装的工具、显示手动待办事项 |

```shell
make pre-config      # 系统检查
make pre-install     # 包管理器
make install         # 软件安装
make post-install    # Shell / 配置
make finalize        # 验证 + 待办
```

## 目录结构

```
dotfile/
├── Makefile                     # 入口，make all 运行全部阶段
├── scripts/
│   ├── pre-config.sh            # Stage 1: 系统检查
│   ├── pre-install.sh           # Stage 2: 包管理器
│   ├── install.sh               # Stage 3: 软件安装
│   ├── post-install.sh          # Stage 4: Shell & 配置
│   ├── finalize.sh              # Stage 5: 验证 & 待办
│   └── lib/utils.sh             # 共享函数库
├── bin/
│   ├── config_cask_list.sh      # GUI 应用列表（brew cask）
│   ├── config_cmd_tool_list.sh  # CLI 工具列表（brew install）
│   ├── config_languagetool_list.sh # 语言工具列表（mise）
│   ├── config_user.sh           # 用户配置（Git name/email、GPG key）
│   └── install.sh               # 兼容旧入口，delegate 到 scripts/install.sh
├── config/
│   ├── fish/config.fish         # Fish shell 配置
│   ├── zsh/.zshrc               # Zsh 配置（Oh My Zsh）
│   ├── ghostty/config           # Ghostty 终端配置
│   ├── starship/starship.toml   # Starship 提示符
│   ├── kitty/kitty.conf         # Kitty 终端配置
│   ├── Alacritty/alacritty.yml  # Alacritty 终端配置
│   ├── iterm2/                  # iTerm2 配置
│   ├── .gnupg/gpg-agent.conf    # GPG agent 配置
│   └── .pip/pip.conf            # pip 镜像源
├── mise.toml                    # mise 版本管理配置
└── .github/workflows/workflow.yml
```

## 自定义

Fork 后修改 `bin/config_user.sh` 中的个人信息：

```shell
GIT_USER_NAME="guzhongren"
GIT_USER_EMAIL="guzhongren@live.cn"
GPG_SIGNING_KEY="D18AEC180356622D"
```

软件列表分别修改 `bin/config_*.sh` 和 `mise.toml`。

## License

MIT
