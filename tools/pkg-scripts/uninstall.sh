#!/bin/bash

readonly LOCAL_DIR="$HOME/.local/share/kio/servicemenus/"

function main() {
  local DESKTOP_FILE="$LOCAL_DIR/resolvetools.desktop"
  local SCRIPT_FOLDER="$LOCAL_DIR/resolvetools-servicemenus"

  rm "$DESKTOP_FILE"
  rm -rf "$SCRIPT_FOLDER"

  echo "Resolve Tools uninstalled"
}

main
