function convert_audio() {
  local -r input_file="$1"

  local -r output_dir="media_files"
  mkdir -p "$output_dir"

  local codec
  codec=$(
    ffprobe -v error \
      -select_streams a:0 \
      -show_entries stream=codec_name \
      -of default=nw=1:nk=1 "$input_file"
  )

  if [[ -z "$codec" ]]; then
    stderr "$(i18n stderr@acodec)"
    return 1
  fi

  local -a ffmpeg_opts=("-vn")
  case "$codec" in
  flac)
    ffmpeg_opts+=("-c:a" "copy")
    ;;
  *)
    ffmpeg_opts+=("-c:a" "flac")
    ;;
  esac

  local -r output_file="$output_dir/$(basename "${input_file%.*}.flac")"

  run_ffmpeg_with_progress "$input_file" "$output_file" "${ffmpeg_opts[@]}"
}
