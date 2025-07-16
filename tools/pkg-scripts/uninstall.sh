#!/bin/env bash

# Strict mode for error handling
set -o errexit -o nounset -o pipefail

# Colors RGB & End
declare -r R="\033[1;31m"
declare -r G="\033[1;32m"
declare -r B="\033[34m"
declare -r Y="\033[1;33m"
declare -r E="\033[0m"

declare -r LOCAL_DIR="$HOME/.local/share/kio/servicemenus"

function stderr() {
  # Log an error message and exit with a non-zero status
  printf >&2 "${R}Error:${E} line(%d) → %s\n" "${BASH_LINENO[0]}" "$*"
  exit 1
}

function main() {
  local -r DESKTOP_FILE="$LOCAL_DIR/resolvetools.desktop"
  local -r SCRIPT_FOLDER="$LOCAL_DIR/resolvetools"
  local status=false

  if [ -f "$DESKTOP_FILE" ]; then
    printf "%b\n" "Removing ${B}${DESKTOP_FILE}${E}"
    rm -- "$DESKTOP_FILE" || stderr "Failed to remove ${DESKTOP_FILE}"
    status=true
  fi

  if [ -d "$SCRIPT_FOLDER" ]; then
    printf "%b\n" "Removing ${B}${SCRIPT_FOLDER}${E}"
    rm -rf -- "$SCRIPT_FOLDER" || stderr "Failed to remove ${SCRIPT_FOLDER}"
    status=true
  fi

  if $status; then
    printf "\n%b\n" "${G}Resolve Tools uninstalled successfully!${E}"
  else
    printf "%b\n" "${Y}Nothing to uninstall.${E}"
  fi
}

main
