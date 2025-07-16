#!/bin/env bash

set -o errexit -o nounset -o pipefail

function log_error() {
  # Log an error message and exit with a non-zero status
  local -r error_message="Error: $*"

  # Show the error box using kdialog
  kdialog --error "$error_message" \
    --title "Resolve Tools Error" \
    --icon "error"
  exit 1
}

# Functions
source "$(dirname "$0")/src/functions/extract_audio.sh"
source "$(dirname "$0")/src/functions/kdialog_debug.sh"
source "$(dirname "$0")/src/functions/kdialog_error.sh"
source "$(dirname "$0")/src/functions/kdialog_progress.sh"
source "$(dirname "$0")/src/functions/new_project.sh"
source "$(dirname "$0")/src/functions/recode_media.sh"
# Locales
source "$(dirname "$0")/src/locales/get_dictionary.sh"
source "$(dirname "$0")/src/locales/get_system_lang.sh"
# Routes
source "$(dirname "$0")/src/routes/folder_routes.sh"

while getopts ":x:y:z:" opt; do
  case $opt in
  x)
    SELECTED_DIR="$OPTARG"

    if [[ ! -d "$SELECTED_DIR" ]]; then
      log_error "Argument for option \"Project Folder\" cannot be a file."
    fi
    new_project
    ;;
  y)
    FILE="$OPTARG"

    if [[ ! -f "$FILE" ]]; then
      log_error "Argument for option \"Recode Media\" must be a file and cannot be empty."
    fi

    convert_video
    ;;
  z)
    AUDIO_FILE="$OPTARG"

    if [[ ! -f "$AUDIO_FILE" ]]; then
      log_error "Argument for option \"Extract Audio\" must be a file and cannot be empty."
    fi

    convert_audio
    ;;
  *)
    log_error "Error: -$OPTARG"
    ;;
  esac
done
