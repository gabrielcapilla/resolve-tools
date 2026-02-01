#!/bin/env bash

# Project folder structure definitions
# Format: lang=folder1:folder2:folder3...

declare -gA FOLDER_STRUCTURE=(
  [en]="Audio/Music:Audio/Voice over:Audio/Sound effects:Footage/A-Roll:Footage/B-Roll:Images:Exports"
  [es]="Audio/Música:Audio/Locución:Audio/Efectos de sonido:Metraje/A-Roll:Metraje/B-Roll:Imágenes:Exportaciones"
)

function get_folders() {
  # Get folder list for current language
  local -r lang="${LANG:0:2}"
  echo "${FOLDER_STRUCTURE["$lang"]:-${FOLDER_STRUCTURE["en"]}}" | tr ':' '\n'
}
