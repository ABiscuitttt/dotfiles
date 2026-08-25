#!/usr/bin/env bash
# 将本仓库中的配置以 symlink 方式部署到家目录。
# 幂等：可重复执行；目标位置已存在的真实文件会先备份为 <路径>.bak.<时间戳>。
# 用法：bash install.sh
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d%H%M%S)"

# ---------- 终端样式（非 TTY 时自动关闭颜色，避免日志混入转义符） ----------
if [ -t 1 ]; then
    B=$'\033[1m'; DIM=$'\033[2m'; RST=$'\033[0m'
    RED=$'\033[31m'; GRN=$'\033[32m'; YEL=$'\033[33m'; CYN=$'\033[36m'
else
    B=''; DIM=''; RST=''; RED=''; GRN=''; YEL=''; CYN=''
fi

n_link=0; n_skip=0; n_bak=0

section() { printf '\n%s%s▸ %s%s\n' "$B" "$CYN" "$1" "$RST"; }

home_rel() { printf '%s' "${1/#$HOME/\~}"; }

link() { # link <仓库内相对路径> <部署绝对路径>
    local src="$DOTFILES/$1" dst="$2" disp
    disp="$(home_rel "$dst")"

    if [ ! -e "$src" ]; then
        printf '  %s✗%s %s %s(仓库内缺少源文件)%s\n' "$RED" "$RST" "$disp" "$DIM" "$RST" >&2
        return 1
    fi

    mkdir -p "$(dirname "$dst")"

    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        printf '  %s✓ %s (已链接)%s\n' "$DIM" "$disp" "$RST"
        n_skip=$((n_skip + 1))
        return
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mv "$dst" "$dst.bak.$TS"
        printf '  %s↺%s %s %s(原文件已备份为 %s.bak.%s)%s\n' "$YEL" "$RST" "$disp" "$DIM" "$disp" "$TS" "$RST"
        n_bak=$((n_bak + 1))
    fi

    ln -s "$src" "$dst"
    printf '  %s+%s %s%s%s\n' "$GRN" "$RST" "$B" "$disp" "$RST"
    n_link=$((n_link + 1))
}

printf '%s%sdotfiles 部署%s %s(%s)%s\n' "$B" "$CYN" "$RST" "$DIM" "$DOTFILES" "$RST"

section "fcitx5 + rime-ice"
link fcitx5/config/classicui.conf     "$HOME/.config/fcitx5/conf/classicui.conf"
link fcitx5/rime/default.custom.yaml  "$HOME/.local/share/fcitx5/rime/default.custom.yaml"
link fcitx5/rime/rime_ice.custom.yaml "$HOME/.local/share/fcitx5/rime/rime_ice.custom.yaml"

section "Claude Code"
link claude/settings.json         "$HOME/.claude/settings.json"
link claude/statusline-command.py "$HOME/.claude/statusline-command.py"

section "zsh"
link shell/zshrc "$HOME/.zshrc"

section "kitty"
link kitty "$HOME/.config/kitty"

printf '\n%s%s完成%s %s(%d 新建链接 · %d 跳过 · %d 备份)%s\n' \
    "$B" "$GRN" "$RST" "$DIM" "$n_link" "$n_skip" "$n_bak" "$RST"

cat <<EOF

${DIM}剩余手动步骤：${RST}
  ${YEL}•${RST} fcitx5：先按 https://github.com/iDvel/rime-ice 把词库铺到 ~/.local/share/fcitx5/rime/，
    再重启 fcitx5：${B}pkill fcitx5; nohup fcitx5 -d >/dev/null 2>&1 & disown${RST}
  ${YEL}•${RST} zsh：安装 oh-my-zsh 与插件并 chsh，命令见 README「zsh 依赖」一节。
EOF
