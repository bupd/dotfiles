#!/bin/sh

# Get the sink number for the specified sink name
# Fill in your appropriate sink name by executing
# $(pactl list short sinks) and pick RUNNING
sink_name="alsa_output.pci-0000_0c_00.4.analog-stereo"
sink_number=$(pactl list short sinks | grep "RUNNING" | awk '{print $1}')

# Display the result
echo "Sink number for $sink_name: $sink_number"

# Load the module-null-sink and display the new sink ID
echo -n "Loading module-null-sink... "
null_sink_id=$(pactl load-module module-null-sink sink_name=music sink_properties=device.description="music")
null_sink_id2=$(pactl load-module module-null-sink sink_name=out sink_properties=device.description="out")

# Get number of null Sink.
null_sink_number=$(pactl list short sinks | grep module-null-sink.c | awk 'NR==1{print $1}')
echo -e "\nNull-Sink Number: ${null_sink_number}"

null_sink_number2=$(pactl list short sinks | grep module-null-sink.c | awk 'END{print $1}')
echo -e "\nNull-Sink Number: ${null_sink_number2}"

# Load the module-combine-sink with the desired slaves and display the new sink ID
echo -n "Loading module-combine-sink with slaves $sink_number and $null_sink_number... "
echo -n "Loading module-combine-sink with slaves $sink_number and $null_sink_number2... "
combine_sink_id=$(pactl load-module module-combine-sink sink_name=forOut slaves=$sink_number,$null_sink_number)
combine_sink_id2=$(pactl load-module module-combine-sink slaves=$sink_number,$null_sink_number2)
# echo "combined_Sink ID: $combine_sink_id"
# echo "combined_Sink ID: $combine_sink_id2"

# echo -e "\n thank you boyy..."


