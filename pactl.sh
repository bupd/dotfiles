#!/bin/sh

# Get the Razer headset sink name
sink_name=$(pactl list short sinks | grep "Razer" | awk '{print $2}')
echo "Using sink: $sink_name"

# Create two null sinks for separate OBS capture
pactl load-module module-null-sink sink_name=null_music sink_properties=device.description="Music-Capture"
pactl load-module module-null-sink sink_name=null_out sink_properties=device.description="Desktop-Capture"
echo "Null sinks created: null_music, null_out"

# Create combine sink for Spotify (music)
pactl load-module module-combine-sink sink_name=sink_music sink_properties=device.description="Spotify-Output" slaves="$sink_name",null_music
echo "sink_music created (for Spotify)"

# Create combine sink for desktop/Brave (out)
pactl load-module module-combine-sink sink_name=sink_out sink_properties=device.description="Desktop-Output" slaves="$sink_name",null_out
echo "sink_out created (for Brave/Desktop)"

# Set desktop output as default
pactl set-default-sink sink_out
echo "Default sink set to sink_out"
