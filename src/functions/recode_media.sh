function start_ffmpeg() {
  # Execute ffmpeg and convert a media file
  ffmpeg \
    -i "$FILE" \
    -c copy \
    -c:a pcm_s16le \
    "$output_file" \
    -progress "$ktemp" >/dev/null 2>&1 &
}

function convert_video() {
  # Main function to convert a video
  local ktemp
  local kprogress
  local output_file
  local duration_seconds

  ktemp=$(mktemp)

  kprogress=$(kdialog_progressbar)

  duration_seconds=$(get_duration "$FILE")

  if [[ -z "$duration_seconds" ]]; then
    qdbus $kprogress close
    stderr ""
    return 1
  fi

  local -r output_dir="optimized_media"

  if [[ ! -d ${output_dir} ]]; then
    mkdir -p "$output_dir"
  fi

  output_file="$output_dir/$(basename "${FILE%.*}.mkv")"

  start_ffmpeg

  local ffmpeg_pid=$!

  monitor_progress "$ffmpeg_pid" "$duration_seconds"
}
