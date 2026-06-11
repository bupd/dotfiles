#!/bin/sh

set -u

app_name="Speech To Text"
model="${STT_MODEL:-base.en}"
source="${STT_SOURCE:-default}"
silence_threshold_db="${STT_SILENCE_THRESHOLD_DB:--70}"
runtime_base="${XDG_RUNTIME_DIR:-/tmp}"

if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
    runtime_dir="$runtime_base/stt"
else
    runtime_dir="$runtime_base/stt-$USER"
fi

pid_file="$runtime_dir/recording.pid"
recording_file="$runtime_dir/recording.wav"
transcript_file="$runtime_dir/transcript.txt"
output_dir="$runtime_dir/whisper-output"
lock_dir="$runtime_dir/lock"

notify() {
    urgency="$1"
    timeout="$2"
    title="$3"
    body="$4"

    if command -v dunstify >/dev/null 2>&1; then
        dunstify -r 9999 -a "$app_name" -u "$urgency" -t "$timeout" "$title" "$body"
    elif command -v notify-send >/dev/null 2>&1; then
        notify-send -a "$app_name" -u "$urgency" -t "$timeout" "$title" "$body"
    fi
}

fail() {
    notify critical 6000 "STT failed" "$1"
    exit 1
}

require_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return
    fi

    case "$1" in
        whisper)
            fail "Missing command: whisper. Install python-openai-whisper."
            ;;
        *)
            fail "Missing command: $1"
            ;;
    esac
}

cleanup_stale_pid() {
    if [ ! -f "$pid_file" ]; then
        return
    fi

    pid="$(tr -d '[:space:]' < "$pid_file")"
    if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
        rm -f "$pid_file"
    fi
}

recording_has_speech() {
    max_volume_db="$(ffmpeg -hide_banner -nostats -i "$recording_file" -af volumedetect -f null - 2>&1 |
        while IFS= read -r line; do
            case "$line" in
                *"max_volume:"*)
                    value="${line#*max_volume: }"
                    printf '%s\n' "${value%% dB*}"
                    ;;
            esac
        done)"
    if [ -z "$max_volume_db" ]; then
        fail "Could not measure recording volume."
    fi

    case "$max_volume_db" in
        -inf|inf)
            return 1
            ;;
    esac

    [ "${max_volume_db%%.*}" -gt "$silence_threshold_db" ]
}

start_recording() {
    require_command ffmpeg
    require_command whisper
    require_command xdotool

    rm -f "$recording_file" "$transcript_file"
    rm -rf "$output_dir"
    mkdir -p "$output_dir"

    ffmpeg -y -hide_banner -loglevel error \
        -f pulse -i "$source" \
        -ar 16000 -ac 1 \
        "$recording_file" >/dev/null 2>&1 &

    printf '%s\n' "$!" > "$pid_file"
    notify normal 0 "STT ON" "Recording. Press Ctrl+\\ again to stop."
}

stop_recording() {
    if [ ! -f "$pid_file" ]; then
        notify normal 2500 "STT" "No active recording."
        return
    fi

    pid="$(tr -d '[:space:]' < "$pid_file")"
    if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
        rm -f "$pid_file"
        notify normal 2500 "STT" "No active recording."
        return
    fi

    require_command whisper
    require_command xdotool
    require_command ffmpeg

    notify low 1200 "STT" "Recording saved."
    kill -INT "$pid" 2>/dev/null || true

    count=0
    while kill -0 "$pid" 2>/dev/null && [ "$count" -lt 30 ]; do
        sleep 0.1
        count=$((count + 1))
    done

    if kill -0 "$pid" 2>/dev/null; then
        kill -TERM "$pid" 2>/dev/null || true
        sleep 0.2
    fi

    rm -f "$pid_file"

    if [ ! -s "$recording_file" ]; then
        fail "Recording file is empty."
    fi

    if ! recording_has_speech; then
        notify normal 3500 "STT" "No speech detected. Check STT_SOURCE or microphone input."
        return
    fi

    rm -rf "$output_dir"
    mkdir -p "$output_dir"

    notify normal 0 "STT" "Transcribing with Whisper $model."

    if ! whisper "$recording_file" \
        --model "$model" \
        --language en \
        --task transcribe \
        --fp16 False \
        --output_format txt \
        --output_dir "$output_dir" >/dev/null 2>&1; then
        fail "Whisper transcription failed."
    fi

    whisper_txt="$output_dir/$(basename "${recording_file%.*}").txt"
    if [ ! -f "$whisper_txt" ]; then
        fail "Whisper did not produce a transcript."
    fi

    tr '\n\r\t' '   ' < "$whisper_txt" | awk '{$1=$1; print}' > "$transcript_file"

    if [ ! -s "$transcript_file" ] || [ -z "$(tr -d '[:space:][:punct:]' < "$transcript_file")" ]; then
        notify normal 3500 "STT" "No speech detected."
        return
    fi

    if ! xdotool type --clearmodifiers --delay 0 --file "$transcript_file"; then
        fail "Could not type transcript with xdotool."
    fi

    notify low 2500 "STT" "Inserted transcript."
}

mkdir -p "$runtime_dir" || fail "Could not create runtime directory: $runtime_dir"
if ! mkdir "$lock_dir" 2>/dev/null; then
    notify normal 2500 "STT" "Already processing."
    exit 0
fi
trap 'rmdir "$lock_dir" 2>/dev/null || true' EXIT INT TERM

cleanup_stale_pid

case "${1:-toggle}" in
    --start)
        start_recording
        ;;
    --stop)
        stop_recording
        ;;
    toggle)
        if [ -f "$pid_file" ]; then
            stop_recording
        else
            start_recording
        fi
        ;;
    *)
        fail "Usage: stt-start.sh [--start|--stop]"
        ;;
esac
