#!/bin/sh
set -eu

target_sink=${TARGET_SINK:-}

if [ -z "$target_sink" ]; then
	target_sink=$(pactl list sinks | awk '
		/^[[:space:]]*Name:/ { name = $2 }
		/^[[:space:]]*Description:/ && index($0, "Starship/Matisse") {
			print name
			exit
		}
	')
fi

if [ -z "$target_sink" ]; then
	echo "Could not find Starship/Matisse output sink." >&2
	exit 1
fi

echo "Using sink: $target_sink"

# Remove this script's old virtual sinks so reruns keep the routing correct.
for module in $(pactl list short modules | awk '$2 == "module-combine-sink" && $0 ~ /sink_name=sink_(music|out)/ { print $1 }'); do
	pactl unload-module "$module"
done

for module in $(pactl list short modules | awk '$2 == "module-null-sink" && $0 ~ /sink_name=null_(music|out)/ { print $1 }'); do
	pactl unload-module "$module"
done

# Create two null sinks for separate OBS capture
pactl load-module module-null-sink sink_name=null_music sink_properties=device.description="Music-Capture" >/dev/null
pactl load-module module-null-sink sink_name=null_out sink_properties=device.description="Desktop-Capture" >/dev/null
echo "Null sinks created: null_music, null_out"

# Create combine sink for Spotify (music)
pactl load-module module-combine-sink sink_name=sink_music sink_properties=device.description="Spotify-Output" slaves="$target_sink,null_music" >/dev/null
echo "sink_music created (for Spotify)"

# Create combine sink for desktop/Brave (out)
pactl load-module module-combine-sink sink_name=sink_out sink_properties=device.description="Desktop-Output" slaves="$target_sink,null_out" >/dev/null
echo "sink_out created (for Brave/Desktop)"

# Set desktop output as default
pactl set-default-sink sink_out
echo "Default sink set to sink_out"
