#!/bin/env bash

# Strict mode for error handling
set -o errexit -o nounset -o pipefail

declare -r LOCAL_DIR="$HOME/.local/share/kio/servicemenus"
declare -r TARGET_DIR="$LOCAL_DIR/resolvetools"

# Colors RGB & End
declare -r R="\033[1;31m"
declare -r G="\033[1;32m"
declare -r B="\033[34m"
declare -r E="\033[0m"

function stderr() {
  # Log an error message and exit with a non-zero status
  printf >&2 "${R}Error:${E} line(%d) → %s\n" "${BASH_LINENO[0]}" "$*"
  exit 1
}

function get_script_dir() {
  # Get the directory of the script
  local -r SELF_PATH="$(realpath -- "${BASH_SOURCE[0]}")"
  dirname -- "${SELF_PATH}"
}

function make_folder() {
  # Make the ./resolvetools folder
  if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p -- "$TARGET_DIR" || stderr "Failed to create directory."
  fi

  printf "%b\n\n" "Directory ${B}${TARGET_DIR}${E} created successfully."
}

function install_script() {
  # Copy the resolvetools files to .local/share/kio/servicemenus
  local -r FILES="$(get_script_dir)/.."

  printf "%b\n" "Copying ${B}$(realpath -- "${FILES}/src")${E}"
  cp -r -- "${FILES}/src" "$TARGET_DIR" || stderr "Failed copying ${FILES}/src"

  printf "%b\n" "Copying ${B}$(realpath -- "${FILES}/init.sh")${E}"
  cp -- "${FILES}/init.sh" "$TARGET_DIR" || stderr "Failed copying ${FILES}/init.sh"

  for desktop_file in "${FILES}/desktop/"*.desktop; do
    printf "%b\n" "Copying ${B}$(realpath -- "${desktop_file}")${E}"
    chmod +x -- "$desktop_file" || stderr "Failure to add execution permissions ${desktop_file}"
    cp -- "$desktop_file" "$LOCAL_DIR" || stderr "Failed copying ${desktop_file}"
  done
}

function main() {
  # Main function orchestrating the script flow
  make_folder
  install_script

  printf "\n%b\n" "${G}Resolve Tools installed successfully!${E}"
}

main
