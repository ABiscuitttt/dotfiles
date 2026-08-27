#!/usr/bin/env powershell
# 将本仓库中的配置以 symlink 方式部署到家目录。
# 幂等：可重复执行；目标位置已存在的真实文件会先备份为 <路径>.bak.<时间戳>。
# 用法：powershell -ExecutionPolicy Bypass -File install.ps1
# 注意：Windows 默认需要以管理员权限运行才能创建符号链接（除非已开启「开发者模式」）。

param(
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

$DOTFILES = $PSScriptRoot
if (-not $DOTFILES) {
    $DOTFILES = Split-Path -Parent $MyInvocation.MyCommand.Path
}
$TS = Get-Date -Format "yyyyMMddHHmmss"

$ESC = [char]27
$colors = @{
    Reset   = "$ESC[0m"
    Bold    = "$ESC[1m"
    Dim     = "$ESC[2m"
    Red     = "$ESC[31m"
    Green   = "$ESC[32m"
    Yellow  = "$ESC[33m"
    Cyan    = "$ESC[36m"
}

$nLink = 0
$nSkip = 0
$nBak = 0

function Home-Rel($Path) {
    return $Path -replace [regex]::Escape($HOME), "~"
}

function Is-Symlink($Path) {
    $item = Get-Item -Path $Path -ErrorAction SilentlyContinue
    return ($item -ne $null) -and ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
}

function Get-SymlinkTarget($Path) {
    $item = Get-Item -Path $Path -ErrorAction SilentlyContinue
    if ($item -and $item.PSObject.Properties['Target']) {
        $t = $item.Target
        if ($t -is [System.Array]) { return $t[0] }
        return $t
    }
    return $null
}

function Link($RelPath, $DstPath) {
    $src = Join-Path $DOTFILES $RelPath
    $disp = Home-Rel $DstPath

    if (-not (Test-Path $src)) {
        Write-Host "  $($colors.Red)✗$($colors.Reset) $disp $($colors.Dim)(仓库内缺少源文件)$($colors.Reset)" -ForegroundColor Red
        return
    }

    $dstDir = Split-Path -Parent $DstPath
    if (-not (Test-Path $dstDir)) {
        if ($WhatIf) {
            Write-Host "  $($colors.Dim)would create directory: $dstDir$($colors.Reset)"
        }
        else {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }
    }

    if ((Test-Path $DstPath) -and (Is-Symlink $DstPath)) {
        $currentTarget = Get-SymlinkTarget $DstPath
        # Normalize paths for comparison
        $normCurrent = if ($currentTarget) { (Resolve-Path $currentTarget -ErrorAction SilentlyContinue).Path } else { $null }
        $normSrc = (Resolve-Path $src).Path
        if ($normCurrent -eq $normSrc) {
            Write-Host "  $($colors.Dim)✓ $disp (已链接)$($colors.Reset)"
            $script:nSkip++
            return
        }
    }

    if (Test-Path $DstPath) {
        $bak = "$DstPath.bak.$TS"
        if ($WhatIf) {
            Write-Host "  $($colors.Yellow)↺$($colors.Reset) $disp $($colors.Dim)(原文件将备份为 $disp.bak.$TS)$($colors.Reset)"
        }
        else {
            Move-Item -Path $DstPath -Destination $bak -Force
            Write-Host "  $($colors.Yellow)↺$($colors.Reset) $disp $($colors.Dim)(原文件已备份为 $disp.bak.$TS)$($colors.Reset)"
        }
        $script:nBak++
    }

    if ($WhatIf) {
        Write-Host "  $($colors.Green)+$($colors.Reset) $($colors.Bold)$disp$($colors.Reset) (would link to $src)"
        $script:nLink++
        return
    }

    $srcItem = Get-Item $src
    $isDir = $srcItem.PSIsContainer

    if ($isDir) {
        # 目录符号链接需要管理员权限
        New-Item -ItemType SymbolicLink -Path $DstPath -Value $src | Out-Null
    }
    else {
        New-Item -ItemType SymbolicLink -Path $DstPath -Value $src | Out-Null
    }

    Write-Host "  $($colors.Green)+$($colors.Reset) $($colors.Bold)$disp$($colors.Reset)"
    $script:nLink++
}

function Section($Title) {
    Write-Host "`n$($colors.Bold)$($colors.Cyan)▸ $Title$($colors.Reset)"
}

Write-Host "$($colors.Bold)$($colors.Cyan)dotfiles 部署$($colors.Reset) $($colors.Dim)($DOTFILES)$($colors.Reset)"
if ($WhatIf) {
    Write-Host "$($colors.Yellow)WhatIf 模式：不会实际修改文件$($colors.Reset)"
}

Section "fcitx5 + rime-ice"
Link "fcitx5/config/classicui.conf"     "$HOME/.config/fcitx5/conf/classicui.conf"
Link "fcitx5/rime/default.custom.yaml"  "$HOME/.local/share/fcitx5/rime/default.custom.yaml"
Link "fcitx5/rime/rime_ice.custom.yaml" "$HOME/.local/share/fcitx5/rime/rime_ice.custom.yaml"

Section "Claude Code"
Link "claude/settings.json"         "$HOME/.claude/settings.json"
Link "claude/statusline-command.py" "$HOME/.claude/statusline-command.py"

Section "zsh"
Link "shell/zshrc" "$HOME/.zshrc"

Section "kitty"
Link "kitty" "$HOME/.config/kitty"

Write-Host "`n$($colors.Bold)$($colors.Green)完成$($colors.Reset) $($colors.Dim)($nLink 新建链接 · $nSkip 跳过 · $nBak 备份)$($colors.Reset)"

Write-Host "`
$($colors.Dim)剩余手动步骤：$($colors.Reset)
  $($colors.Yellow)•$($colors.Reset) fcitx5：先按 https://github.com/iDvel/rime-ice 把词库铺到 ~/.local/share/fcitx5/rime/，
    再重启 fcitx5：$($colors.Bold)pkill fcitx5; nohup fcitx5 -d >/dev/null 2>&1 & disown$($colors.Reset)
  $($colors.Yellow)•$($colors.Reset) zsh：安装 oh-my-zsh 与插件并 chsh，命令见 README「zsh 依赖」一节。
  $($colors.Yellow)•$($colors.Reset) 如果 kitty 目录链接失败，请用管理员权限重新运行本脚本。
"
