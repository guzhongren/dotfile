
#!/bin/bash

echo "===== Shell 信息检查 (跨平台版) ====="
echo ""

# 获取当前用户
CURRENT_USER=$(whoami)
echo "当前用户: $CURRENT_USER"
echo ""

# 1. 当前登录用户的默认shell（来自$SHELL变量）
echo "1. 用户默认shell (\$SHELL 变量):"
if [ -n "$SHELL" ]; then
    echo "   $SHELL"
else
    echo "   \$SHELL 变量未设置"
fi
echo ""

# 2. 当前正在使用的shell
echo "2. 当前正在使用的shell:"
CURRENT_SHELL=$(ps -p $$ -o comm= 2>/dev/null || echo "无法获取进程信息")
echo "   进程名: $CURRENT_SHELL"
echo "   进程ID: $$"
echo ""

# 3. Shell的版本信息
echo "3. Shell版本信息:"
case "$CURRENT_SHELL" in
    *bash*)
        if [ -n "$BASH_VERSION" ]; then
            echo "   bash: $BASH_VERSION"
        else
            echo "   bash: 版本信息不可用"
        fi
        ;;
    *zsh*)
        if [ -n "$ZSH_VERSION" ]; then
            echo "   zsh: $ZSH_VERSION"
        else
            echo "   zsh: 版本信息不可用"
        fi
        ;;
    *fish*)
        if command -v fish >/dev/null 2>&1; then
            fish --version 2>/dev/null || echo "   fish: 版本信息不可用"
        else
            echo "   fish: 未安装"
        fi
        ;;
    *sh*)
        echo "   sh: 版本信息通常不可用"
        ;;
    *)
        echo "   $CURRENT_SHELL: 版本信息不可用"
        ;;
esac
echo ""

# 4. 跨平台获取用户配置的shell
echo "4. 验证用户shell配置:"

# 方法1: 从/etc/passwd获取 (macOS/Linux通用)
USER_SHELL=""
if [ -f /etc/passwd ]; then
    USER_SHELL=$(grep "^$CURRENT_USER:" /etc/passwd | cut -d: -f7 2>/dev/null || echo "")
fi

# 方法2: 备用方法获取用户shell
if [ -z "$USER_SHELL" ]; then
    if command -v dscl >/dev/null 2>&1; then
        # macOS
        USER_SHELL=$(dscl . -read /Users/$CURRENT_USER UserShell 2>/dev/null | awk '{print $2}' || echo "")
    elif command -v getent >/dev/null 2>&1; then
        # Linux
        USER_SHELL=$(getent passwd $CURRENT_USER 2>/dev/null | cut -d: -f7 || echo "")
    else
        USER_SHELL="未知 (无法获取)"
    fi
fi

echo "   用户 $CURRENT_USER 配置的shell: $USER_SHELL"
echo ""

# 5. 系统可用的有效shell列表
echo "5. 系统有效shell列表:"
if [ -f /etc/shells ]; then
    echo "   --- 有效的shell (/etc/shells) ---"
    cat /etc/shells
    echo "   ---------------------------------"
    
    # 检查用户shell是否在有效列表中
    if [ -n "$USER_SHELL" ] && [ "$USER_SHELL" != "未知 (无法获取)" ]; then
        if grep -q "^$USER_SHELL$" /etc/shells; then
            echo "   ✓ 用户shell在有效列表中"
        else
            echo "   ✗ 警告: 用户shell不在有效列表中!"
        fi
    else
        echo "   无法验证用户shell有效性"
    fi
else
    echo "   /etc/shells 文件不存在"
fi
echo ""

# 6. 检查shell配置文件
echo "6. Shell配置文件状态:"
SHELL_CONFIG_FILES=(
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.bash_login"
    "$HOME/.profile"
    "$HOME/.zshrc"
    "$HOME/.zshenv"
    "$HOME/.zprofile"
    "$HOME/.zlogin"
    "$HOME/.config/fish/config.fish"
)

for config_file in "${SHELL_CONFIG_FILES[@]}"; do
    if [ -f "$config_file" ]; then
        echo "   ✓ $config_file (存在)"
    elif [ -L "$config_file" ]; then
        echo "   🔗 $config_file (符号链接)"
    fi
done
echo ""

# 7. 检查常见shell的安装情况和路径
echo "7. 已安装的shell及路径:"
declare -A SHELL_PATHS
SHELLS=("bash" "zsh" "fish" "dash" "sh" "tcsh" "csh" "ksh")

for shell in "${SHELLS[@]}"; do
    if command -v $shell >/dev/null 2>&1; then
        SHELL_PATH=$(which $shell 2>/dev/null || command -v $shell)
        SHELL_PATHS["$shell"]="$SHELL_PATH"
        echo "   ✓ $shell: $SHELL_PATH"
    else
        echo "   ✗ $shell: 未安装"
    fi
done
echo ""

# 8. 获取详细的shell信息
echo "8. 详细shell信息:"
echo "   系统类型: $(uname -s) $(uname -r)"
echo "   架构: $(uname -m)"
echo "   主机名: $(hostname 2>/dev/null || echo "未知")"
echo "   当前目录: $(pwd)"
echo "   终端: $TERM"
echo "   终端模拟器: ${TERM_PROGRAM:-未知}"
echo ""

# 9. 更改shell的建议命令
echo "9. 更改shell的建议命令:"
if [ -n "${SHELL_PATHS[bash]}" ]; then
    echo "   更改为bash:    chsh -s ${SHELL_PATHS[bash]}"
fi
if [ -n "${SHELL_PATHS[zsh]}" ]; then
    echo "   更改为zsh:     chsh -s ${SHELL_PATHS[zsh]}"
fi
if [ -n "${SHELL_PATHS[fish]}" ]; then
    echo "   更改为fish:    chsh -s ${SHELL_PATHS[fish]}"
    # 检查fish是否在/etc/shells中
    if [ -f /etc/shells ] && ! grep -q "^${SHELL_PATHS[fish]}$" /etc/shells; then
        echo "   注意: fish 不在 /etc/shells 中，需要先添加:"
        echo "     echo '${SHELL_PATHS[fish]}' | sudo tee -a /etc/shells"
    fi
fi
echo ""

# 10. 检查当前shell的功能
echo "10. 当前shell功能测试:"
echo "   变量扩展测试:"
TEST_VAR="test_value"
if [ "$TEST_VAR" = "test_value" ]; then
    echo "   ✓ 变量扩展正常"
else
    echo "   ✗ 变量扩展异常"
fi

echo "   命令执行测试:"
if ls >/dev/null 2>&1; then
    echo "   ✓ 命令执行正常"
else
    echo "   ✗ 命令执行异常"
fi
echo ""

# 11. 检查登录shell和交互式shell
echo "11. Shell模式检查:"
case "$-" in
    *i*)
        echo "   当前是交互式shell"
        ;;
    *)
        echo "   当前是非交互式shell"
        ;;
esac

if shopt -q login_shell 2>/dev/null; then
    echo "   当前是登录shell (bash)"
elif [ "$0" = "-bash" ] || [ "$0" = "-zsh" ] || [ "$0" = "-sh" ]; then
    echo "   当前是登录shell"
else
    echo "   当前不是登录shell"
fi
echo ""

echo "===== 检查完成 ====="
