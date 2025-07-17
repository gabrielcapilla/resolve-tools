function convert_audio() {
  local -r input_file="$1"
  # Convert an audio stream to a FLAC file with progress display.

  local -r FILE="$input_file"
  local ktemp
  local kprogress
  local duration_seconds

  kprogress=$(kdialog_progressbar)
  ktemp=$(mktemp)

  duration_seconds=$(get_duration "$input_file")
  if [[ -z "$duration_seconds" ]]; then
    qdbus "$kprogress" close
    stderr "$(i18n stderr@acodec)"
    return 1
  fi

  local CODEC
  CODEC=$(
    ffprobe -v error \
      -select_streams a:0 \
      -show_entries stream=codec_name \
      -of default=nw=1:nk=1 "$input_file"
  )

  if [[ -z "$CODEC" ]]; then
    qdbus "$kprogress" close
    stderr "$(i18n stderr@acodec)"
    return 1
  fi

  local FFMPEG_OPTS
  case "$CODEC" in
  flac)
    FFMPEG_OPTS=("-c:a" "copy")
    ;;
  *)
    FFMPEG_OPTS=("-c:a" "flac")
    ;;
  esac

  # Execute ffmpeg in the background, reporting progress to the temp file.
  ffmpeg -i "$input_file" -y -vn "${FFMPEG_OPTS[@]}" "${input_file%.*}.flac" \
    -progress "$ktemp" >/dev/null 2>&1 &

  local ffmpeg_pid=$!
  monitor_progress "$ffmpeg_pid" "$duration_seconds"
}
