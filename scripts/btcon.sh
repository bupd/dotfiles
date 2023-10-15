#!/bin/bash

bar="C3:44:80:82:10:19"
air="80:EF:A9:DF:79:96"

echo "Which device you need to connect: "
read device 

bluetoothctl remove $bar
bluetoothctl remove $air

bluetoothctl scan on
sleep 3
bluetoothctl scan off
connect ()
{
 local name=$1
 if [[ $name = "bar" ]]; then
  bluetoothctl connect $bar
 elif [[ $name = "air" ]]; then
   bluetoothctl connect $air
 fi
}

connect "$device"
