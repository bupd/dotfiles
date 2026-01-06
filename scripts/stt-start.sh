#!/bin/sh
pkill -x nerd-dictation
dunstify -r 9999 -t 0 "STT ON"
nerd-dictation begin --vosk-model-dir=/usr/share/vosk-models/small-en-us --timeout 3
