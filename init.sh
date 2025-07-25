#!/bin/env bash

set -o errexit -o nounset -o pipefail

# Functions
source "$(dirname "$0")/src/functions/media_utils.sh"
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
      stderr "Option '-x' requires a directory, but received a file."
    fi

    new_project "$INPUT_PATH"
    ;;

  y | z)
    # Options for processing a media file
    INPUT_PATH="$OPTARG"
    if [[ ! -f "$INPUT_PATH" ]]; then
      stderr "Option '-$opt' requires an existing file."
    fi

    if [[ "$opt" == "y" ]]; then
      convert_video "$INPUT_PATH"
    else # opt is "z"
      convert_audio "$INPUT_PATH"
    fi
    ;;

  *)
    stderr "Invalid option: -$OPTARG"
    ;;
  esac
done
