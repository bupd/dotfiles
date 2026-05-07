#!/bin/bash

# List of required programs
required_programs=(
    "stow"
    "git"
    "i3"
    "i3status"
    "fzf"
    "alacritty"     # NOTE: may be stale — kitty is now the primary terminal
    "xdotool"
    "xbindkeys"
    "tmux"
    "nvim"
    "picom"
    "pactl"
    "zsh"
    "bash"
    "xremap"
    "kitty"
    "lazygit"
    "asdf"              # NOTE: may be stale — consider replacing with mise or removing
    "microsoft-edge-stable"  # NOTE: may be stale — verify this is still in use
    "node"              # NOTE: may be stale if managed via asdf/mise
    "ng"                # NOTE: may be stale — Angular CLI, verify still needed
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
    echo "All required programs are installed. & make sure sudo cmds can run without password"
else
    echo "The following programs are missing:"
    for program in "${missing_programs[@]}"; do
        echo "- $program"
    done
    echo "Please install the missing programs and try again."
fi

