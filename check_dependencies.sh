#!/bin/bash

# List of required programs
required_programs=(
    "stow"
    "git"
    "i3"
    "i3status"
    "fzf"
    "kitty"
    "xdotool"
    "xbindkeys"
    "tmux"
    "nvim"
    "picom"
    "pactl"
    "zsh"
    "bash"
    "xremap"
    "asdf"
    "microsoft-edge-stable"
    "spotify"
    "node"
    "ng"
)

# Check for missing programs
missing_programs=()
for program in "${required_programs[@]}"; do
    if ! command -v "$program" &> /dev/null; then
        missing_programs+=("$program")
    fi
done

# Check if spotify-adblock is installed
if ! [ -f /usr/lib/spotify-adblock.so ]; then
    missing_programs+=("spotify-adblock")
fi

# Report missing programs
if [ ${#missing_programs[@]} -eq 0 ]; then
    echo "All required programs are installed. & make sure sudo cmds can run without password"
else
    echo "The following programs are missing:"
    for program in "${missing_programs[@]}"; do
        echo "- $program"
    done
    echo "Please install the missing programs and try again."
fi

