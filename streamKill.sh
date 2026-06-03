#!/bin/sh
# Tear down streaming audio setup (screenkey, PulseAudio sinks)
pkill screenkey
pactl unload-module module-combine-sink
pactl unload-module module-null-sink

echo "Good stream BTW!!"
