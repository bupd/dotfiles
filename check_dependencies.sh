#!/bin/bash

# List of required programs
required_programs=(
    "stow"
    "git"
    "i3"
    "i3status"
    "fzf"
    "kitty"
    "tmux"
    "nvim"
    "picom"
    "pactl"
    "zsh"
    "bash"
)

# Check for missing programs
missing_programs=()
for program in "${required_programs[@]}"; do
    if ! command -v "$program" &> /dev/null; then
        missing_programs+=("$program")
    fi
done

# Report missing programs
if [ ${#missing_programs[@]} -eq 0 ]; then
    echo "All required programs are installed."
else
    echo "The following programs are missing:"
    for program in "${missing_programs[@]}"; do
        echo "- $program"
    done
    echo "Please install the missing programs and try again."
fi

