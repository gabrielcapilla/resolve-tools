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
    # Option for creating a new project in a directory
    INPUT_PATH="$OPTARG"
    if [[ ! -d "$INPUT_PATH" ]]; then
      log_error "Option '-x' requires a directory, but received a file."
    fi

    # Set the global variable expected by new_project.sh
    SELECTED_DIR="$INPUT_PATH"
    new_project
    ;;

  y | z)
    # Options for processing a media file
    INPUT_PATH="$OPTARG"
    if [[ ! -f "$INPUT_PATH" ]]; then
      log_error "Option '-$opt' requires an existing file."
    fi

    if [[ "$opt" == "y" ]]; then
      # Set the global variable expected by recode_media.sh
      FILE="$INPUT_PATH"
      convert_video
    else # opt is "z"
      # Set the global variable expected by extract_audio.sh
      AUDIO_FILE="$INPUT_PATH"
      convert_audio
    fi
    ;;

  *)
    log_error "Invalid option: -$OPTARG"
    ;;
  esac
done
