#!/usr/bin/env python3
import json
import os
import subprocess
import sys

CYAN, GREEN, YELLOW, RED, DIM, RESET = '\033[36m', '\033[32m', '\033[33m', '\033[31m', '\033[90m', '\033[0m'
BAR_WIDTH = 10
PARTIAL_BLOCKS = ' ▏▎▍▌▋▊▉'


def fmt(n):
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.1f}k"
    return str(n)


def render_bar(pct):
    color = RED if pct >= 90 else YELLOW if pct >= 70 else GREEN
    full, partial = divmod(pct * BAR_WIDTH * 8 // 100, 8)
    filled = '█' * full + (PARTIAL_BLOCKS[partial] if partial else '')
    empty = '░' * (BAR_WIDTH - full - bool(partial))
    return f"{color}{filled}{RESET}{DIM}{empty}{RESET}"


def git_branch(cwd):
    try:
        out = subprocess.check_output(
            ['git', 'branch', '--show-current'],
            cwd=cwd, text=True, stderr=subprocess.DEVNULL, timeout=1,
        ).strip()
    except (subprocess.SubprocessError, FileNotFoundError):
        return ""
    return f" | {out}" if out else ""


data = json.load(sys.stdin)
model = data['model']['display_name']
workspace = data['workspace']['current_dir']
ctx = data.get('context_window') or {}
pct = int(ctx.get('used_percentage') or 0)
total_in = int(ctx.get('total_input_tokens') or 0)
window = int(ctx.get('context_window_size') or 0)
cache_read = int((ctx.get('current_usage') or {}).get('cache_read_input_tokens') or 0)

parts = [f"{render_bar(pct)} {pct}%"]
if window:
    parts.append(f"{fmt(total_in)}/{fmt(window)}")
if cache_read > 0:
    parts.append(f"cache {fmt(cache_read)}")

print(f"{CYAN}[{model}]{RESET} {os.path.basename(workspace)}{git_branch(workspace)}")
print(" · ".join(parts))
