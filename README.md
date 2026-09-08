# Blacklotus's Dotfiles

Arch Linux + i3wm, managed with [GNU stow](https://www.gnu.org/software/stow/).
The repo **is** the live system: every config in `~/.config` and `~` is a
symlink into this directory.

## Stack

| Layer      | Tool                                            |
|------------|--------------------------------------------------|
| OS / WM    | Arch Linux, i3                                   |
| Bar        | polybar (`launch.sh` starts `main` + `second`)   |
| Launcher   | rofi (`$mod+d`, powermenu `$mod+x`, etc.)        |
| Terminal   | alacritty (TOML config; the old `.yml` is dead)  |
| Shell      | zsh + oh-my-zsh (`/usr/share/oh-my-zsh`)         |
| Editor     | Neovim + LazyVim (`lazy-lock.json` pins plugins) |
| Music      | mpd (user service) + ncmpcpp + rmpc              |
| Compositor | picom · notifications: dunst · lock: i3lock      |

## Layout

```
<pkg>/.config/<pkg>/...   app configs — stow packages, target is $HOME
zsh/ bash/ x/ git/        home dotfiles (.zshrc, .bashrc, .xinitrc, .gitconfig)
scripts/                  helper scripts -> /usr/local/bin (rofi-powermenu, lock, ...)
fonts/                    OpenSans, RobotoMono, Iosevka, Feather -> /usr/share/fonts
wallpapers/               referenced by i3 as ~/Pictures/wallpapers/background.png
themes/                   GTK theme (RosePine-Main)
packages/                 pacman-explicit.txt + aur.txt (curated)
install.sh                one-shot reproduction script
```

## Restore on a fresh machine

```sh
git clone git@github.com:Blacklotus89898/dotfiles.git
cd dotfiles
./install.sh              # everything: packages, fonts, scripts, theme, stow, services
```

Steps can be run individually: `./install.sh packages configs`.

Post-install (manual):
```sh
sudo systemctl enable sddm
chsh -s /usr/bin/zsh
```

## Day-to-day

```sh
cd ~/dotfiles
stow -t ~ <pkg>            # activate a package
stow -t ~ -D <pkg>         # deactivate
vim i3/.config/i3/config   # edit anything — it IS the live config
$mod+Shift+r               # reload i3, done
git add -A && git commit   # then push
```

Neovim: plugins are pinned by `nvim/.config/nvim/lazy-lock.json`. After changing
plugins run `:Lazy` to sync and commit the updated lockfile. LSP servers are
installed by Mason into `~/.local/share/nvim/mason/` (not tracked — reinstall
with `:Mason`).

## Rollback

- Repo history is granular; find a state with `git log`, restore a file with
  `git checkout <sha> -- path`, or the whole tree with `git reset --hard <sha>`.
- If a stow package misbehaves: `stow -t ~ -D <pkg>` (unlinks), restore your
  old file, re-stow.

## Notes

- `~/.git-credentials`, `.ssh/`, `.gnupg/` are never committed (see .gitignore).
- mpd database, ncmpcpp lyrics/logs are app state — ignored, regenerated.
- Keyitdev's original dotfiles (base of this rice) kept at
  `~/dotfiles.keyitdev-backup` until you delete it.
