# dotfiles

个人配置文件备份。

## fcitx5 + rime-ice

雾凇拼音 (rime-ice) 自定义配置。

| 仓库路径 | 部署位置 |
|---|---|
| `fcitx5/rime/default.custom.yaml` | `~/.local/share/fcitx5/rime/default.custom.yaml` |
| `fcitx5/rime/rime_ice.custom.yaml` | `~/.local/share/fcitx5/rime/rime_ice.custom.yaml` |
| `fcitx5/config/classicui.conf` | `~/.config/fcitx5/conf/classicui.conf` |

### 部署

1. 先按 [rime-ice](https://github.com/iDvel/rime-ice) 把仓库铺到 `~/.local/share/fcitx5/rime/`
2. 把上表的三个文件覆盖到对应位置
3. 重启 fcitx5: `pkill fcitx5; nohup fcitx5 -d >/dev/null 2>&1 & disown`
