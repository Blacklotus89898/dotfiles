#!/usr/bin/env bash
# Master setup — reproduces this Arch + i3 rice from a bare Arch install.
#
# Requirements: fresh Arch with network and a sudo-capable non-root user.
#
#   git clone git@github.com:Blacklotus89898/dotfiles.git
#   cd dotfiles
#   ./setup.sh                # everything
#   ./setup.sh packages stow  # or individual steps
#
# Steps: prereqs update packages fonts scripts theme wallpapers stow
#        services tweaks checklist
set -euo pipefail

DOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUR_HELPER="${AUR_HELPER:-yay}"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log()   { printf "${GREEN}[setup]${NC} %s\n" "$*"; }
warn()  { printf "${YELLOW}[setup]${NC} %s\n" "$*"; }

# ---------------------------------------------------------------- checks ----
check_env() {
    [ "$(id -u)" -ne 0 ] || { echo "run as a normal user with sudo, not root"; exit 1; }
    sudo -v
    [ -f /etc/arch-release ] || warn "not an Arch system — continuing anyway"
    if ! ping -c1 -W3 archlinux.org &>/dev/null; then
        echo "no network connection to archlinux.org"; exit 1
    fi
    log "environment OK"
}

# ------------------------------------------------------------------ steps ---
prereqs() {
    log "installing build tools, git, stow"
    sudo pacman -S --needed --noconfirm base-devel git stow curl wget unzip zip
}

update() {
    log "full system update"
    sudo pacman -Syu --noconfirm
}

packages() {
    log "installing $(wc -l < "$DOTDIR/packages/pacman-explicit.txt") pacman packages"
    sudo pacman -S --needed --noconfirm - < "$DOTDIR/packages/pacman-explicit.txt"

    # AUR helper
    if ! command -v "$AUR_HELPER" &>/dev/null; then
        log "building $AUR_HELPER from AUR"
        rm -rf /tmp/aur-helper && git clone --depth 1 \
            "https://aur.archlinux.org/${AUR_HELPER}.git" /tmp/aur-helper
        (cd /tmp/aur-helper && makepkg -si --noconfirm)
    fi

    log "installing missing AUR packages"
    local missing=()
    while read -r pkg; do
        pacman -Qi "$pkg" &>/dev/null || missing+=("$pkg")
    done < "$DOTDIR/packages/aur.txt"
    if [ "${#missing[@]}" -gt 0 ]; then
        "$AUR_HELPER" -S --needed --noconfirm "${missing[@]}"
    else
        log "AUR packages already present"
    fi
}

fonts() {
    log "installing fonts"
    sudo cp "$DOTDIR"/fonts/*.ttf /usr/share/fonts/
    sudo fc-cache -f >/dev/null
}

scripts() {
    log "installing helper scripts -> /usr/local/bin (rofi-powermenu, lock, ...)"
    sudo cp "$DOTDIR"/scripts/* /usr/local/bin/
    sudo chmod 755 /usr/local/bin/*
}

theme() {
    log "installing GTK theme + wallpapers"
    sudo mkdir -p /usr/share/themes
    sudo cp -r "$DOTDIR/themes/RosePine-Main" /usr/share/themes/
}

wallpapers() {
    log "installing wallpapers -> ~/Pictures/wallpapers"
    mkdir -p ~/Pictures
    cp -r "$DOTDIR/wallpapers" ~/Pictures/
}

stow_configs() {
    log "stowing all packages into \$HOME"
    local pkg rel target
    for pkg in "$DOTDIR"/*/; do
        pkg="$(basename "$pkg")"
        case "$pkg" in scripts|fonts|wallpapers|packages|themes) continue ;; esac
        # move conflicting real files aside so stow can symlink
        (cd "$DOTDIR/$pkg" && find . -mindepth 1 \( -type f -o -type l \) -printf '%P\n') |
        while read -r rel; do
            target="$HOME/$rel"
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                mv "$target" "$target.pre-stow.$(date +%s)"
                warn "backed up conflicting $target"
            fi
        done
        stow -t "$HOME" "$pkg" 2>/dev/null && log "stowed: $pkg" || warn "stow $pkg: already linked or skipped"
    done
}

services() {
    log "enabling user services"
    systemctl --user enable --now mpd.service 2>/dev/null || warn "mpd user service not enabled"
}

tweaks() {
    log "system tweaks"
    if command -v sddm &>/dev/null; then
        sudo systemctl enable sddm 2>/dev/null || true
    else
        warn "sddm not installed — skipping display-manager enable"
    fi
    # pacman parallel downloads
    if ! grep -q "^ParallelDownloads" /etc/pacman.conf; then
        sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf
        log "set ParallelDownloads=5 in /etc/pacman.conf"
    fi
    # zsh as login shell
    if [ "$SHELL" != "/usr/bin/zsh" ] && command -v zsh &>/dev/null; then
        sudo chsh -s /usr/bin/zsh "$USER" 2>/dev/null && log "login shell -> zsh" \
            || warn "could not chsh (run: sudo chsh -s /usr/bin/zsh $USER)"
    fi
}

checklist() {
    log "install complete. manual checklist:"
    cat <<EOF
  1. relogin / reboot (sddm -> i3, zsh, environment vars)
  2. nvim LSP tooling:        open nvim, run :Mason  (tools reinstall themselves)
  3. spotify polybar module:  appears once a player is running
  4. passwords/ssh:           copy .git-credentials, .ssh/, .gnupg/ from backup
                              (never committed to the repo)
  5. verify symlinks:         ls -la ~/.config | grep '\->'
EOF
}

# ------------------------------------------------------------------ runner --
STEPS="${*:-prereqs update packages fonts scripts theme wallpapers stow_configs services tweaks checklist}"

check_env
for step in $STEPS; do
    case "$step" in
        prereqs)     prereqs ;;
        update)      update ;;
        packages)    packages ;;
        fonts)       fonts ;;
        scripts)     scripts ;;
        theme)       theme ;;
        wallpapers)  wallpapers ;;
        stow)        stow_configs ;;
        stow_configs) stow_configs ;;
        services)    services ;;
        tweaks)      tweaks ;;
        checklist)   checklist ;;
        *)           echo "unknown step: $step" >&2; exit 1 ;;
    esac
done
