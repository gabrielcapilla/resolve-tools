#!/bin/env bash

# Strict mode for error handling
set -o errexit -o nounset -o pipefail

declare -r BUILD_DIR="build"
declare -r RESOLVETOOLS_DIR="$BUILD_DIR/resolvetools"

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

function make_folder() {
  # Make the ./build folder
  if [ ! -d "$RESOLVETOOLS_DIR" ]; then
    mkdir -p -- "$RESOLVETOOLS_DIR" || stderr "Failed to create ${R}$RESOLVETOOLS_DIR${E} directory."
  fi

  printf "%b\n\n" "Temporal directory ${B}/$BUILD_DIR${E} created successfully."
}

function copy_files() {
  # Copy the resolvetools files to build directory
  local -r FILES="$(get_script_dir)/.."

  printf "%b\n" "Copying ${B}$(realpath -- "${FILES}/src")${E}"
  cp -r -- "${FILES}/src" "${RESOLVETOOLS_DIR}" || stderr "Failed copying ${FILES}/src"

  printf "%b\n" "Copying ${B}$(realpath -- "${FILES}/init.sh")${E}"
  cp -- "${FILES}/init.sh" "$RESOLVETOOLS_DIR" || stderr "Failed copying ${FILES}/init.sh"

  for desktop_file in "${FILES}/desktop/"*.desktop; do
    printf "%b\n" "Copying ${B}$(realpath -- "${desktop_file}")${E}"
    cp -- "$desktop_file" "$BUILD_DIR" || stderr "Failed copying ${desktop_file}"
  done

  for scripts_files in "${FILES}/tools/pkg-scripts/"*.sh; do
    printf "%b\n" "Copying ${B}$(realpath -- "${scripts_files}")${E}"
    cp -- "$scripts_files" "$BUILD_DIR" || stderr "Failed copying ${scripts_files}"
  done
}

function make_compress() {
  # Compress the build directory into a tar.xz file
  pushd "$BUILD_DIR" >/dev/null || stderr "Failed to change directory to ${BUILD_DIR}"
  tar -cJf "../resolvetools.tar.xz" . || stderr "Failed to create tar.xz file"
  popd >/dev/null || stderr "Failed to return to original directory"

  printf "\n%b\n" "File ${B}resolvetools.tar.xz${E} created successfully."
}

function clean_build() {
  # Clean up the build directory
  rm -rf -- "$BUILD_DIR" || stderr "Failed to clean${R} ${BUILD_DIR} ${E}directory"

  printf "\n%b\n" "Temporal directory ${B}/$BUILD_DIR ${E}cleaned successfully."
}

function main() {
  # Main function orchestrating the script flow
  trap clean_build EXIT
  make_folder
  copy_files
  make_compress

  printf "\n%b\n" "${G}Successfully packed!${E}"
}

main
