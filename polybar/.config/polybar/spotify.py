#!/usr/bin/env python3
"""Spotify module for polybar — playerctl (MPRIS) backend.

Usage:
    spotify.py                     print clickable polybar label
    spotify.py prev|toggle|next    control the player

Prefers spotify, falls back to any MPRIS player. Prints nothing when no
player is active, so the module hides itself.
"""
import subprocess
import sys

PLAYER = "spotify,spotifyd,%any"
SCRIPT = "$HOME/.config/polybar/spotify.py"
DIM = "%{F#6b7089}"
RESET = "%{F-}"

ICONS = {
    "play": "\uf04b",
    "pause": "\uf04c",
    "prev": "\uf04a",
    "next": "\uf04e",
}
MAX_TITLE = 45


def ctl(*args: str) -> str:
    result = subprocess.run(
        ["playerctl", "-p", PLAYER, *args],
        capture_output=True, text=True,
    )
    return result.stdout.strip()


def act(action: str) -> None:
    if not ctl("status"):
        return
    if action == "toggle":
        ctl("play-pause")
    else:
        ctl(action)


def track() -> str:
    artist = ctl("metadata", "artist")
    title = ctl("metadata", "title")
    text = f"{artist} - {title}" if artist else title
    if len(text) > MAX_TITLE:
        text = text[: MAX_TITLE - 1].rstrip() + "…"
    return text


def label() -> str:
    status = ctl("status")
    if not status:
        return ""
    playing = status == "Playing"
    toggle_icon = ICONS["play"] if playing else ICONS["pause"]
    state = "" if playing else f"{DIM}[paused]{RESET} "
    title = track() or "spotify"

    def btn(action: str, icon: str) -> str:
        return f"%{{A1:{SCRIPT} {action} &:}}{icon}%{{A}}"

    return (
        f"{btn('prev', ICONS['prev'])} "
        f"{btn('toggle', toggle_icon)} "
        f"{btn('next', ICONS['next'])} "
        f"{btn('toggle', f'{state}{title}')}"
    )


if __name__ == "__main__":
    if len(sys.argv) > 1:
        act(sys.argv[1])
    print(label(), end="")
