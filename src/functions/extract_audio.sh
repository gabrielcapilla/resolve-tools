function convert_audio() {
  # Convert an audio stream to a FLAC file.

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

  # Set ffmpeg options based on the codec.
  # The goal is to always produce a valid FLAC file, discarding video (-vn).
  local FFMPEG_OPTS
  case "$CODEC" in
  flac)
    # If the source is already flac, just copy the stream to avoid re-encoding.
    FFMPEG_OPTS=("-c:a" "copy")
    ;;
  *)
    # For all other codecs, re-encode the audio stream to the 'flac' codec.
    FFMPEG_OPTS=("-c:a" "flac")
    ;;
  esac

  # Execute ffmpeg with the determined options.
  ffmpeg -i "$AUDIO_FILE" -y -vn "${FFMPEG_OPTS[@]}" "${AUDIO_FILE%.*}.flac"
}
