function convert_video() {
  local -r input_file="$1"

  local video_codec
  video_codec=$(
    ffprobe -v error \
      -select_streams v:0 \
      -show_entries stream=codec_name \
      -of default=nw=1:nk=1 "$input_file"
  )

  if [[ -z "$video_codec" ]]; then
    stderr "$(i18n stderr@vcodec)"
    return 1
  fi

  local -a ffmpeg_opts

  case "$video_codec" in
  h264 | hevc | prores | dnxhd)
    ffmpeg_opts=("-c:v" "copy")
    ;;

  vp8 | vp9 | av1 | theora | mpeg4 | mpeg2video | wmv3)
    if command -v nvidia-smi &>/dev/null; then
      # NVIDIA GPU (NVENC)
      ffmpeg_opts=("-c:v" "h264_nvenc" "-cq" "24" "-preset" "p6")
    elif [ -e "/dev/dri/renderD128" ]; then
      # AMD/Intel GPU (VA-API)
      ffmpeg_opts=("-vaapi_device" "/dev/dri/renderD128" "-c:v" "h264_vaapi" "-qp" "24" "-vf" "format=nv12,hwupload")
    else
      # Fallback a CPU (Software)
      ffmpeg_opts=("-c:v" "libx264" "-crf" "22" "-preset" "slow" "-pix_fmt" "yuv420p")
    fi
    ;;

  *)
    ffmpeg_opts=("-c:v" "dnxhd" "-profile:v" "dnxhr_sq" "-pix_fmt" "yuv422p")
    ;;
  esac

  ffmpeg_opts+=("-c:a" "pcm_s16le")

  local -r input_dir="$(dirname "$1")"
  local -r output_dir="$input_dir/media_files"
  mkdir -p "$output_dir"
  local -r output_file="$output_dir/$(basename "${input_file%.*}.mkv")"

  run_ffmpeg_with_progress "$input_file" "$output_file" "${ffmpeg_opts[@]}"
}
