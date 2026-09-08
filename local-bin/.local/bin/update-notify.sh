#!/bin/bash
# Notifies via dunst when system or AUR updates are available.
set -euo pipefail

count=0
out="$(checkupdates 2>/dev/null || true)"
[ -n "$out" ] && count=$(echo "$out" | wc -l)

aur_count=0
aur="$(yay -Qua 2>/dev/null || true)"
[ -n "$aur" ] && aur_count=$(echo "$aur" | wc -l)

total=$((count + aur_count))
if [ "$total" -gt 0 ]; then
    dunstify -a "updates" -u normal -r 2001 -t 12000 \
        -h string:x-dunst-stack-tag:updates \
        "${total} updates available" \
        "${count} repo, ${aur_count} AUR — run: yay"
fi
