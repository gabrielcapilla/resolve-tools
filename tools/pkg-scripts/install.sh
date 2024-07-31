#!/bin/bash

readonly LOCAL_DIR="$HOME/.local/share/kio/servicemenus/"

function main() {
  local DESKTOP_FILE
  DESKTOP_FILE="$(dirname "$0")/resolvetools.desktop"

  local SCRIPT_FOLDER
  SCRIPT_FOLDER="$(dirname "$0")/resolvetools-servicemenus"

  cp "$DESKTOP_FILE" "$LOCAL_DIR"
  cp -r "$SCRIPT_FOLDER" "$LOCAL_DIR"

  echo "Resolve Tools 0.2.0 installed"
}

main
