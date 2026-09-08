#!/bin/bash
# Dotfiles installer — reproduces this Arch + i3 setup from scratch.
# Idempotent: safe to re-run. Assumes a fresh-ish Arch system with git + sudo.
#
# Usage:  ./install.sh [steps...]
#         ./install.sh            # run everything
#         ./install.sh packages   # just packages
#         ./install.sh configs    # just stow
set -euo pipefail

DOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUR_HELPER="${AUR_HELPER:-yay}"

log() { printf '\033[0;32m[install]\033[0m %s\n' "$*"; }

require_pacman() {
    sudo pacman -S --needed --noconfirm - < "$DOTDIR/packages/pacman-explicit.txt"
}

install_aur_helper() {
    if ! command -v "$AUR_HELPER" &>/dev/null; then
        log "building $AUR_HELPER from AUR"
        git clone --depth 1 "https://aur.archlinux.org/${AUR_HELPER}-bin.git" /tmp/aur-helper
        (cd /tmp/aur-helper && makepkg -si --noconfirm)
    fi
}

require_aur() {
    command -v "$AUR_HELPER" &>/dev/null || { echo "no AUR helper; run install.sh packages first" >&2; exit 1; }
    # Install AUR packages not already present
    local missing=()
    while read -r pkg; do
        pacman -Qi "$pkg" &>/dev/null || missing+=("$pkg")
    done < "$DOTDIR/packages/aur.txt"
    ((${#missing[@]})) && "$AUR_HELPER" -S --needed --noconfirm "${missing[@]}" || true
}

install_fonts() {
    log "installing fonts to /usr/share/fonts"
    sudo cp "$DOTDIR"/fonts/*.ttf /usr/share/fonts/
    sudo fc-cache -f >/dev/null
}

install_scripts() {
    log "installing helper scripts to /usr/local/bin (fixes \$mod+i/x/c/z binds)"
    sudo cp "$DOTDIR"/scripts/* /usr/local/bin/
    sudo chmod +x /usr/local/bin/*
}

install_theme() {
    log "installing RosePine GTK theme + Papirus icons"
    if [ -d "$DOTDIR/themes/RosePine-Main" ]; then
        sudo cp -r "$DOTDIR/themes/RosePine-Main" /usr/share/themes/
    fi
}

stow_configs() {
    log "stowing configs into \$HOME (backup any conflicting files first)"
    command -v stow &>/dev/null || sudo pacman -S --needed --noconfirm stow
    # move conflicting live files aside so stow can link
    find "$DOTDIR" -mindepth 1 -maxdepth 1 -type d \
        ! -name '.*' ! -name scripts ! -name fonts ! -name wallpapers ! -name packages ! -name themes -printf '%f\n' |
    while read -r pkg; do
        # back up real files that would conflict
        (cd "$DOTDIR/$pkg" && find . -mindepth 1 \( -type f -o -type l \) | sed 's|^\./||') |
        while read -r rel; do
            local target="$HOME/$rel"
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                mv "$target" "$target.pre-stow.$(date +%s)"
            fi
        done
        stow -t "$HOME" "$pkg"
        log "stowed: $pkg"
    done
}

enable_services() {
    log "enabling user services (mpd)"
    systemctl --user enable --now mpd.service 2>/dev/null || true
    # wallpapers (i3 references $HOME/Pictures/wallpapers/background.png)
    mkdir -p ~/Pictures
    cp -rn "$DOTDIR/wallpapers" ~/Pictures/ 2>/dev/null || true
}

post_install() {
    log "post-install checklist (manual):"
    echo "  - enable sddm:            sudo systemctl enable sddm"
    echo "  - pacman.conf tweak:      ParallelDownloads = 5"
    echo "  - reload i3 after login:  \$mod+Shift+r"
    echo "  - zsh as login shell:     chsh -s /usr/bin/zsh"
}

STEPS="${*:-packages fonts scripts theme configs services post}"

for step in $STEPS; do
    case "$step" in
        packages) install_aur_helper; require_pacman; require_aur ;;
        fonts)    install_fonts ;;
        scripts)  install_scripts ;;
        theme)    install_theme ;;
        configs)  stow_configs ;;
        services) enable_services ;;
        post)     post_install ;;
        *)        echo "unknown step: $step" >&2; exit 1 ;;
    esac
done

log "done."
