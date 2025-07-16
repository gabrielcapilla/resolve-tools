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
  # Calculate the progress percentage of a media conversion.
  # Usage: calculate_progress <time_microseconds> <total_duration_seconds>
  local time_ms=$1
  local duration_seconds=$2
  local progress_seconds percent

  progress_seconds=$(echo "scale=2; $time_ms / 1000000" | bc)
  percent=$(echo "scale=2; (($progress_seconds / $duration_seconds) * 100) / 1" | bc)

  echo "${percent%.*}"
}
