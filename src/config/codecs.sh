#!/bin/env bash

# Pure data: Codec configurations
# Format: codec_name | type | hw_accel | options
# type: copy | transcode
# hw_accel: none | auto

declare -gA CODEC_CONFIG=(
  # Video codecs - can be copied directly
  [h264]="video|copy|none|-c:v copy -c:a pcm_s16le"
  [hevc]="video|copy|none|-c:v copy -c:a pcm_s16le"
  [prores]="video|copy|none|-c:v copy -c:a pcm_s16le"
  [dnxhd]="video|copy|none|-c:v copy -c:a pcm_s16le"

  # Video codecs - need transcoding with hw acceleration
  [vp8]="video|transcode|auto|-c:a pcm_s16le"
  [vp9]="video|transcode|auto|-c:a pcm_s16le"
  [av1]="video|transcode|auto|-c:a pcm_s16le"
  [theora]="video|transcode|auto|-c:a pcm_s16le"
  [mpeg4]="video|transcode|auto|-c:a pcm_s16le"
  [mpeg2video]="video|transcode|auto|-c:a pcm_s16le"
  [wmv3]="video|transcode|auto|-c:a pcm_s16le"
  [msmpeg4v2]="video|transcode|auto|-c:a pcm_s16le"

  # Audio codecs
  [flac]="audio|copy|none|-vn -c:a copy"
  [aac]="audio|transcode|none|-vn -c:a flac"
  [mp3]="audio|transcode|none|-vn -c:a flac"
  [opus]="audio|transcode|none|-vn -c:a flac"
  [vorbis]="audio|transcode|none|-vn -c:a flac"
)

# Hardware acceleration options by type
declare -gA HW_ACCEL_OPTS=(
  [nvidia]="-c:v h264_nvenc -cq 24 -preset p6"
  [vaapi]="-vaapi_device /dev/dri/renderD128 -c:v h264_vaapi -qp 24 -vf format=nv12,hwupload"
  [cpu]="-c:v libx264 -crf 22 -preset slow -pix_fmt yuv420p"
)

# Default options for unknown codecs
declare -r DEFAULT_VIDEO_OPTS="-c:v dnxhd -profile:v dnxhr_sq -pix_fmt yuv422p -c:a pcm_s16le"
declare -r DEFAULT_AUDIO_OPTS="-vn -c:a flac"
