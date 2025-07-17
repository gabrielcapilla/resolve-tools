function convert_audio() {
  # Convert an audio stream to a FLAC file with progress display.

  # The kdialog_progressbar function expects a global FILE variable.
  # We assign AUDIO_FILE to FILE for compatibility.
  local FILE="$AUDIO_FILE"
  local ktemp
  local kprogress
  local duration_seconds

  kprogress=$(kdialog_progressbar)
  ktemp=$(mktemp)

  duration_seconds=$(get_duration "$AUDIO_FILE")
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
      -of default=nw=1:nk=1 "$AUDIO_FILE"
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
  ffmpeg -i "$AUDIO_FILE" -y -vn "${FFMPEG_OPTS[@]}" "${AUDIO_FILE%.*}.flac" \
    -progress "$ktemp" >/dev/null 2>&1 &

  local ffmpeg_pid=$!
  monitor_progress "$ffmpeg_pid" "$duration_seconds"
}
