# create a null_sink for the podcast to get the output to that.
pactl load-module module-null-sink sink_name=Virtual1
pactl load-module module-virtual-source source_name=VirtualMic master=Virtual1.monitor

echo "Please go and change the audio monitor in the obs settings."
