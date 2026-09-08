#!/bin/bash
# Auto-commits and pushes dotfiles when they changed. Safe:
# - commits only if there is something to commit
# - push failures (offline) are non-fatal; retry next run
set -euo pipefail

cd "$HOME/dotfiles"

if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -q -m "auto: sync $(date '+%F %H:%M')"
    echo "committed changes"
fi

timeout 20 git push -q origin main 2>/dev/null || {
    echo "push failed (offline?) — will retry next run"
    exit 0
}
echo "dotfiles in sync"
