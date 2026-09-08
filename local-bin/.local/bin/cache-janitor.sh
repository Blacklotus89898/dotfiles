#!/bin/bash
# Weekly cache janitor — keeps caches and trash from rotting.
# Safe: only touches cache dirs and trash items older than 30 days.
set -euo pipefail

freed_before=$(df --output=used -B1G / | tail -1 | tr -dc '0-9')

# AUR build caches (biggest offender: go module caches inside)
# || true: root-owned build leftovers abort rm; sudo rm -rf fixes permanently
[ -d "$HOME/.cache/yay" ] && rm -rf "$HOME/.cache/yay"/* 2>/dev/null || true

# language toolchain caches
command -v pip    &>/dev/null && pip    cache purge  &>/dev/null || true
command -v go     &>/dev/null && go     clean -cache &>/dev/null || true
command -v pnpm   &>/dev/null && pnpm   store prune  &>/dev/null || true
[ -d "$HOME/.cache/go-build" ] && rm -rf "$HOME/.cache/go-build"

# trash: remove items older than 30 days (file + its .trashinfo)
TRASH="$HOME/.local/share/Trash"
if [ -d "$TRASH/files" ]; then
    find "$TRASH/files" -mindepth 1 -maxdepth 1 -mtime +30 -print0 |
    while IFS= read -r -d '' item; do
        name="$(basename "$item")"
        rm -rf -- "$item" "$TRASH/info/$name.trashinfo"
    done
fi

freed_after=$(df --output=used -B1G / | tail -1 | tr -dc '0-9')
echo "cache-janitor: root usage ${freed_before}G -> ${freed_after}G"
