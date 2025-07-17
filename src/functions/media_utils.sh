#!/bin/env bash

function get_duration() {
  # Get the duration of a media file in seconds using ffprobe.
  # Usage: get_duration "path/to/file"
  local media_file="$1"
  ffprobe \
    -v error \
    -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 \
    "$media_file"
}

function calculate_progress() {
  local -r time_us=$1
  local -r duration_s=$2

  awk -v time_us="$time_us" -v duration_s="$duration_s" 'BEGIN {
    if (duration_s == 0) {
      print 100;
      exit;
    }
    percent = (time_us / 1000000 / duration_s) * 100;
    if (percent > 100) {
      print 100;
    } else {
      printf "%.0f\n", percent;
    }
  }'
}

function run_ffmpeg_with_progress() {
  local -r input_file="$1"
  local -r output_file="$2"
  local -ar ffmpeg_opts=("${@:3}")

  local ktemp
  ktemp=$(mktemp)

  local kprogress
  kprogress=$(kdialog_progressbar "$(i18n kprogress@progress) $(basename "$input_file")")

  local duration_seconds
  duration_seconds=$(get_duration "$input_file")

  if [[ -z "$duration_seconds" ]]; then
    qdbus "$kprogress" close
    stderr "Could not determine media duration for $input_file."
    return 1
  fi

  ffmpeg -i "$input_file" -y "${ffmpeg_opts[@]}" "$output_file" \
    -progress "file:$ktemp" -nostats -v quiet >/dev/null 2>&1 &

  local -r ffmpeg_pid=$!

  monitor_progress "$ffmpeg_pid" "$duration_seconds" "$kprogress" "$ktemp"
}
