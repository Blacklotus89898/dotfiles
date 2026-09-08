#!/usr/bin/env python3
import sys
import subprocess
import json

def play():
    subprocess.call(['playerctl', 'play'])

def pause():
    subprocess.call(['playerctl', 'pause'])

def next_track():
    subprocess.call(['playerctl', 'next'])

def prev_track():
    subprocess.call(['playerctl', 'previous'])

def status():
    result = subprocess.run(['playerctl', 'status'], capture_output=True, text=True)
    return result.stdout.strip()

def title():
    result = subprocess.run(['playerctl', 'metadata', 'title'], capture_output=True, text=True)
    return result.stdout.strip()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        command = sys.argv[1]
        if command == 'play':
            play()
        elif command == 'pause':
            pause()
        elif command == 'next':
            next_track()
        elif command == 'prev':
            prev_track()
    else:
        current_status = status()
        current_title = title()
        if current_status == 'Playing':
            print(f" {current_title}")
        else:
            print(f" {current_title}")

