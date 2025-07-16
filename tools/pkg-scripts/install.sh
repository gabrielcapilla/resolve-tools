#!/bin/env bash

# Strict mode for error handling
set -o errexit -o nounset -o pipefail

declare -r LOCAL_DIR="$HOME/.local/share/kio/servicemenus"

# Colors RGB & End
declare -r R="\033[1;31m"
declare -r G="\033[1;32m"
declare -r B="\033[34m"
declare -r E="\033[0m"

function stderr() {
  # Log an error message and exit with a non-zero status
  printf >&2 "${R}Error: ${E}line(%d) → %s\n" "${BASH_LINENO[0]}" "$*"
  exit 1
}

function get_script_dir() {
  # Get the directory of the script
  local -r SELF_PATH="$(realpath -- "${BASH_SOURCE[0]}")"
  dirname -- "${SELF_PATH}"
}

function main() {
  local -r DESKTOP_FILE="$(get_script_dir)/resolvetools.desktop"
  local -r SCRIPT_FOLDER="$(get_script_dir)/resolvetools"

  printf "%b\n" "Copying${B} $(realpath -- "${DESKTOP_FILE}")${E}"
  chmod +x -- "$DESKTOP_FILE" || stderr "Failure to add execution permissions ${DESKTOP_FILE}"
  cp -- "$DESKTOP_FILE" "$LOCAL_DIR" || stderr "Failed copying ${DESKTOP_FILE}"

  printf "%b\n" "Copying${B} $(realpath -- "${SCRIPT_FOLDER}")${E}"
  cp -r "$SCRIPT_FOLDER" "$LOCAL_DIR" || stderr "Failed copying ${SCRIPT_FOLDER}"

  printf "\n%b\n" "${G}Resolve Tools installed successfully!${E}"
}

main
