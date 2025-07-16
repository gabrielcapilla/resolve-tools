function convert_audio() {
  # Convert an video file to FLAC format based on its codec

  local CODEC
  CODEC=$(
    # Detect the audio codec of the input file
    ffprobe -v error \
      -select_streams a:0 \
      -show_entries stream=codec_name \
      -of default=nw=1:nk=1 "$AUDIO_FILE"
  )

  if [[ -z "$CODEC" ]]; then
    # If no codec detected, print an error message and exit
    stderr "$(i18n stderr@acodec)"
    return 1
  fi

  # Convert the audio file based on its codec
  case "$CODEC" in
  aac)
    ffmpeg \
      -i "$AUDIO_FILE" \
      -map 0:a \
      -y "${AUDIO_FILE%.*}.flac"
    ;;
  opus | vorbis | mp3)
    ffmpeg \
      -i "$AUDIO_FILE" \
      -y \
      -vn \
      -c:a flac \
      "${AUDIO_FILE%.*}.flac"
    ;;
  wav)
    ffmpeg \
      -i "$AUDIO_FILE" \
      -y \
      -c copy \
      "${AUDIO_FILE%.*}.flac"
    ;;
  alac | ac3 | dts)
    ffmpeg \
      -i "$AUDIO_FILE" \
      -y \
      -c:a flac \
      "${AUDIO_FILE%.*}.flac"
    ;;
  *)
    ffmpeg \
      -i "$AUDIO_FILE" \
      -y \
      -c copy \
      -vn \
      "${AUDIO_FILE%.*}.flac"
    ;;
  esac
}
