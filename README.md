# dotfiles

个人配置文件备份，通过 symlink 部署。

## fcitx5 + rime-ice

雾凇拼音 (rime-ice) 自定义配置。

| 仓库路径 | 部署位置 |
|---|---|
| `fcitx5/rime/default.custom.yaml` | `~/.local/share/fcitx5/rime/default.custom.yaml` |
| `fcitx5/rime/rime_ice.custom.yaml` | `~/.local/share/fcitx5/rime/rime_ice.custom.yaml` |
| `fcitx5/config/classicui.conf` | `~/.config/fcitx5/conf/classicui.conf` |

### 新机器部署

```bash
git clone git@github.com:ABiscuitttt/dotfiles.git ~/Projects/dotfiles

# 先按 https://github.com/iDvel/rime-ice 把仓库铺到 ~/.local/share/fcitx5/rime/

ln -sf ~/Projects/dotfiles/fcitx5/rime/default.custom.yaml   ~/.local/share/fcitx5/rime/default.custom.yaml
ln -sf ~/Projects/dotfiles/fcitx5/rime/rime_ice.custom.yaml  ~/.local/share/fcitx5/rime/rime_ice.custom.yaml
ln -sf ~/Projects/dotfiles/fcitx5/config/classicui.conf      ~/.config/fcitx5/conf/classicui.conf

pkill fcitx5; sleep 1; nohup fcitx5 -d >/dev/null 2>&1 & disown

日常工作流

改 fcitx5 配置工具或直接编辑 ~/Projects/dotfiles/ 里的文件均可，两边等价。改完：

cd ~/Projects/dotfiles && git add -A && git commit -m "..." && git push
