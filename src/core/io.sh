#!/bin/env bash

# Side effects: I/O operations and external process management
# These functions perform actual operations (file system, ffmpeg, dialogs)

function get_duration() {
  # Get media duration using ffprobe
  ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1" 2>/dev/null
}

function detect_codec() {
  # Detect codec for specific stream type
  # Arguments: file_path stream_type (a:0 or v:0)
  ffprobe -v error -select_streams "$2" -show_entries stream=codec_name -of default=nw=1:nk=1 "$1" 2>/dev/null
}

function process_media() {
  # Run ffmpeg with progress dialog
  # Arguments: input_file output_file ffmpeg_options...
  local -r input="$1" output="$2"
  shift 2
  local -a opts=("$@")

  local duration
  duration=$(get_duration "$input")
  [[ -z "$duration" ]] && {
    stderr "Could not determine media duration for $input"
    return 1
  }

  local temp
  temp=$(mktemp)
  local progress
  progress=$(kdialog_progress "$(i18n kprogress_title)" "$(i18n kprogress_progress) $(basename "$input")")

  ffmpeg -i "$input" -y "${opts[@]}" "$output" -progress "file:$temp" -nostats -v quiet &>/dev/null &
  local pid=$!

  monitor_progress "$pid" "$duration" "$progress" "$temp"
}

function extract_audio() {
  # Extract audio from video file
  local -r input="$1"
  local codec
  codec=$(detect_codec "$input" "a:0")

  valid_codec "$codec" "audio" || {
    stderr "$(i18n stderr_acodec)"
    return 1
  }

  local opts
  opts=$(build_opts "$codec")
  local output
  output="media_files/$(basename "${input%.*}.flac")"

  mkdir -p "media_files"
  process_media "$input" "$output" $opts
}

function recode_video() {
  # Recode video for DaVinci Resolve
  local -r input="$1"
  local codec
  codec=$(detect_codec "$input" "v:0")

  valid_codec "$codec" "video" || {
    stderr "$(i18n stderr_vcodec)"
    return 1
  }

  local hw
  hw=$(detect_hw)
  local opts
  opts=$(build_opts "$codec" "$hw")
  local outdir
  outdir="$(dirname "$input")/media_files"
  local output
  output="$outdir/$(basename "${input%.*}.mkv")"

  mkdir -p "$outdir"
  process_media "$input" "$output" $opts
}
