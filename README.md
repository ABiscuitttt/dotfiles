# dotfiles

个人配置文件备份，通过 symlink 部署。

## 目录结构

| 仓库路径 | 部署位置 |
|---|---|
| `fcitx5/config/classicui.conf` | `~/.config/fcitx5/conf/classicui.conf` |
| `fcitx5/rime/default.custom.yaml` | `~/.local/share/fcitx5/rime/default.custom.yaml` |
| `fcitx5/rime/rime_ice.custom.yaml` | `~/.local/share/fcitx5/rime/rime_ice.custom.
| `claude/settings.json` | `~/.claude/settings.json` |

## 新机器部署

```bash
git clone git@github.com:ABiscuitttt/dotfiles.git ~/Projects/dotfiles

# fcitx5 + rime-ice
# 先按 https://github.com/iDvel/rime-ice 铺到 ~/.local/share/fcitx5/rime/
ln -sf ~/Projects/dotfiles/fcitx5/config/classicui.conf      ~/.config/fcitx5/conf/classicui.conf
ln -sf ~/Projects/dotfiles/fcitx5/rime/default.custom.yaml   ~/.local/share/fcitx5/rime/default.custom.yaml
ln -sf ~/Projects/dotfiles/fcitx5/rime/rime_ice.custom.yaml  ~/.local/share/fcitx5/rime/rime_ice.custom.yaml
pkill fcitx5; nohup fcitx5 -d >/dev/null 2>&1 & disown

# Claude Code
mkdir -p ~/.claude
ln -sf ~/Projects/dotfiles/claude/settings.json ~/.claude/settings.json

日常工作流

直接改家目录里的文件（它们是仓库的 symlink），改完：

cd ~/Projects/dotfiles && git add -A && git commit -m "..." && git push
