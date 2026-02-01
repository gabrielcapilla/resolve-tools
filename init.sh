#!/bin/env bash

set -o errexit -o nounset -o pipefail

function source_all() {
  # Auto-source all modules
  local base
  base="$(dirname "$0")/src"
  for dir in config core functions locales routes; do
    for f in "$base/$dir"/*.sh; do
      [[ -f "$f" ]] && source "$f"
    done
  done
}

source_all

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
    [[ ! -f "$INPUT_PATH" ]] && stderr "Option '-$opt' requires an existing file."

    if [[ "$opt" == "y" ]]; then recode_video "$INPUT_PATH"; else extract_audio "$INPUT_PATH"; fi
    ;;

  *)
    stderr "Invalid option: -$OPTARG"
    ;;
  esac
done
