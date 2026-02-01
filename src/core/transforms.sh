#!/bin/env bash

# Pure functions: Data transformations (no side effects)
# These functions only transform data, never perform I/O

function codec_config() {
  # Get codec configuration
  # Returns: type | hw_accel | options
  local -r codec="$1"
  echo "${CODEC_CONFIG[$codec]:-}"
}

function codec_can_copy() {
  # Check if codec can be copied directly
  local -r codec="$1"
  local config
  config=$(codec_config "$codec")
  [[ -n "$config" ]] && [[ "$(echo "$config" | cut -d'|' -f2)" == "copy" ]]
}

function codec_type() {
  # Get media type (audio | video)
  local -r codec="$1"
  local config
  config=$(codec_config "$codec")
  [[ -n "$config" ]] && echo "$config" | cut -d'|' -f1 || echo "unknown"
}

function detect_hw() {
  # Detect hardware acceleration type
  # Returns: nvidia |vaapi | cpu
  command -v nvidia-smi &>/dev/null && echo "nvidia" && return
  [[ -e "/dev/dri/renderD128" ]] && echo "vaapi" && return
  echo "cpu"
}

function build_opts() {
  # Build ffmpeg options for a codec
  # Arguments: codec_name hw_type
  # Returns: complete ffmpeg options string
  local -r codec="$1" hw="${2:-$(detect_hw)}"
  local config
  config=$(codec_config "$codec")

  # Unknown codec - use defaults
  if [[ -z "$config" ]]; then
    [[ "$(codec_type "$codec")" == "audio" ]] && echo "$DEFAULT_AUDIO_OPTS" || echo "$DEFAULT_VIDEO_OPTS"
    return
  fi

  local type
  type=$(echo "$config" | cut -d'|' -f1)
  local mode
  mode=$(echo "$config" | cut -d'|' -f2)
  local hw_auto
  hw_auto=$(echo "$config" | cut -d'|' -f3)
  local base_opts
  base_opts=$(echo "$config" | cut -d'|' -f4)

  # If can copy directly, return base opts
  [[ "$mode" == "copy" ]] && echo "$base_opts" && return

  # If needs transcoding with hw acceleration
  if [[ "$hw_auto" == "auto" && "$type" == "video" ]]; then
    local hw_opts="${HW_ACCEL_OPTS[$hw]:-${HW_ACCEL_OPTS[cpu]}}"
    echo "$hw_opts -c:a pcm_s16le"
    return
  fi

  # Audio transcoding or fallback
  echo "$base_opts"
}

function output_ext() {
  # Get file extension for output
  # Arguments: codec_type
  [[ "$1" == "audio" ]] && echo "flac" || echo "mkv"
}

function valid_codec() {
  # Validate codec detection
  # Arguments: codec_name codec_type
  # Returns: 0 if valid, 1 if empty
  [[ -n "$1" ]] && [[ "$(codec_type "$1")" == "$2" ]]
}
