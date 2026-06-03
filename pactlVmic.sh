#!/bin/sh
# Create a PulseAudio virtual microphone using a null sink for OBS/podcast use
pactl load-module module-null-sink sink_name=Virtual1
pactl load-module module-virtual-source source_name=VirtualMic master=Virtual1.monitor

echo "Please go and change the audio monitor in the obs settings."
