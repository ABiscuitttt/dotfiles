#!/usr/bin/env bash
# 将本仓库中的配置以 symlink 方式部署到家目录。
# 幂等：可重复执行；目标位置已存在的真实文件会先备份为 <路径>.bak.<时间戳>。
# 用法：bash install.sh
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d%H%M%S)"

link() { # link <仓库内相对路径> <部署绝对路径>
    local src="$DOTFILES/$1" dst="$2"

    if [ ! -e "$src" ]; then
        printf '[err]  仓库内缺少 %s\n' "$src" >&2
        return 1
    fi

    mkdir -p "$(dirname "$dst")"

    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        printf '[skip] %s 已是指向本仓库的链接\n' "$dst"
        return
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mv "$dst" "$dst.bak.$TS"
        printf '[bak]  %s -> %s.bak.%s\n' "$dst" "$dst" "$TS"
    fi

    ln -s "$src" "$dst"
    printf '[link] %s -> %s\n' "$dst" "$src"
}

echo "== fcitx5 + rime-ice =="
link fcitx5/config/classicui.conf     "$HOME/.config/fcitx5/conf/classicui.conf"
link fcitx5/rime/default.custom.yaml  "$HOME/.local/share/fcitx5/rime/default.custom.yaml"
link fcitx5/rime/rime_ice.custom.yaml "$HOME/.local/share/fcitx5/rime/rime_ice.custom.yaml"

echo "== Claude Code =="
link claude/settings.json         "$HOME/.claude/settings.json"
link claude/statusline-command.py "$HOME/.claude/statusline-command.py"

echo "== zsh =="
link shell/zshrc "$HOME/.zshrc"

echo "== kitty =="
link kitty "$HOME/.config/kitty"

cat <<'EOF'

完成。剩余手动步骤：
  - fcitx5：先按 https://github.com/iDvel/rime-ice 把词库铺到 ~/.local/share/fcitx5/rime/，
    再重启 fcitx5：pkill fcitx5; nohup fcitx5 -d >/dev/null 2>&1 & disown
  - zsh：安装 oh-my-zsh 与插件并 chsh，命令见 README「zsh 依赖」一节。
EOF
