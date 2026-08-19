# dotfiles

个人配置文件备份，通过 symlink 部署。

## 目录结构

| 仓库路径 | 部署位置 |
|---|---|
| `fcitx5/config/classicui.conf` | `~/.config/fcitx5/conf/classicui.conf` |
| `fcitx5/rime/default.custom.yaml` | `~/.local/share/fcitx5/rime/default.custom.yaml` |
| `fcitx5/rime/rime_ice.custom.yaml` | `~/.local/share/fcitx5/rime/rime_ice.custom.yaml` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `claude/statusline-command.py` | `~/.claude/statusline-command.py` |
| `shell/zshrc` | `~/.zshrc` |
| `kitty/` (整个目录) | `~/.config/kitty` |

## 新机器部署

```bash
# clone 到任意位置，设置 DOTFILES 变量指向仓库目录
git clone git@github.com:ABiscuitttt/dotfiles.git ~/Projects/github-repos/dotfiles
DOTFILES=~/Projects/github-repos/dotfiles

# fcitx5 + rime-ice
# 先按 https://github.com/iDvel/rime-ice 铺到 ~/.local/share/fcitx5/rime/
mkdir -p ~/.config/fcitx5/conf ~/.local/share/fcitx5/rime
ln -sf "$DOTFILES/fcitx5/config/classicui.conf"      ~/.config/fcitx5/conf/classicui.conf
ln -sf "$DOTFILES/fcitx5/rime/default.custom.yaml"   ~/.local/share/fcitx5/rime/default.custom.yaml
ln -sf "$DOTFILES/fcitx5/rime/rime_ice.custom.yaml"  ~/.local/share/fcitx5/rime/rime_ice.custom.yaml
pkill fcitx5; nohup fcitx5 -d >/dev/null 2>&1 & disown

# Claude Code
mkdir -p ~/.claude
ln -sf "$DOTFILES/claude/settings.json"         ~/.claude/settings.json
ln -sf "$DOTFILES/claude/statusline-command.py" ~/.claude/statusline-command.py

# zsh (先装 zsh + oh-my-zsh，见下文)
ln -sf "$DOTFILES/shell/zshrc" ~/.zshrc

# kitty (整个目录 symlink)
rm -rf ~/.config/kitty          # 只有当目录已存在且不是 symlink 时才需要
ln -sfn "$DOTFILES/kitty" ~/.config/kitty
```

### zsh 依赖

```bash
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# .zshrc 里用到的插件：
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions   "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
chsh -s "$(which zsh)"
```

## 日常工作流

直接改家目录里的文件（它们是仓库的 symlink），改完：

```bash
cd "$DOTFILES" && git add -A && git commit -m "..." && git push
```
