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
git clone git@github.com:ABiscuitttt/dotfiles.git ~/Projects/github-repos/dotfiles
cd ~/Projects/github-repos/dotfiles
bash install.sh
```

`install.sh` 会按上表建立全部 symlink，它是幂等的，可重复执行：

- 目标已是指向本仓库的 symlink → 跳过
- 目标位置已有真实文件/目录 → 先备份为 `<路径>.bak.<时间戳>`，再建 symlink
- 只建链接，不安装软件、不重启 fcitx5（见下方提醒）

### Windows 部署

仓库里也提供了 `install.ps1`，用于在 Windows PowerShell 中部署：

```powershell
git clone git@github.com:ABiscuitttt/dotfiles.git $env:USERPROFILE\Projects\github-repos\dotfiles
cd $env:USERPROFILE\Projects\github-repos\dotfiles
powershell -ExecutionPolicy Bypass -File install.ps1
```

Windows 默认需要管理员权限才能创建符号链接（除非已开启「开发者模式」）。可以先 dry-run 预览：

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -WhatIf
```

部署后还需手动完成：

- **fcitx5 + rime-ice**：先按 https://github.com/iDvel/rime-ice 把词库铺到
  `~/.local/share/fcitx5/rime/`，然后重启 fcitx5：

  ```bash
  pkill fcitx5; nohup fcitx5 -d >/dev/null 2>&1 & disown
  ```

### zsh 依赖

`install.sh` 只负责 `~/.zshrc` 的链接，zsh 本体和插件仍需手动安装：

```bash
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# .zshrc 里用到的插件：
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
git clone --depth=1 https://github.com/zsh-users/zsh-completions            "$ZSH_CUSTOM/plugins/zsh-completions"
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
chsh -s "$(which zsh)"
```

## 日常工作流

直接改家目录里的文件（它们是仓库的 symlink），改完：

```bash
cd ~/Projects/github-repos/dotfiles && git add -A && git commit -m "..." && git push
```
