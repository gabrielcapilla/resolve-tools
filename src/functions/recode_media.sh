function convert_video() {
  local -r input_file="$1"

  local -r output_dir="optimized_media"
  mkdir -p "$output_dir"
  local -r output_file="$output_dir/$(basename "${input_file%.*}.mkv")"

  local -a ffmpeg_opts=("-c" "copy" "-c:a" "pcm_s16le")

  run_ffmpeg_with_progress "$input_file" "$output_file" "${ffmpeg_opts[@]}"
}
