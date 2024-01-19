#!/bin/bash

# Customize these variables:
audio_player="mplayer"  # Replace with your preferred player (e.g., mpg123, afplay)
audio_file="/home/bupd/My-Files/beep-01a.mp3"  # Replace with your desired audio file path
prompt_regex="(?i)(password|yes or no|y/n):"  # Regex to match prompts for password or yes/no

# Function to play the audio file
play_audio() {
  $audio_player $audio_file &
  sleep 5
}

# Function to handle input prompts
handle_prompt() {
  local prompt="$1"
  read -p "$prompt" response
  echo "$response"
}

# Trap function to play audio before reading input
trap 'handle_prompt "$BASH_COMMAND"' DEBUG

# # Example usage:
# echo "Enter your password:"
# read -s password
#
# echo "Do you want to continue? (yes/no)"
# read response
#
