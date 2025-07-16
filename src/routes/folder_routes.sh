# English folder structure
declare -a FOLDERS_en=(
  "Audio/Music"
  "Audio/Voice over"
  "Audio/Sound effects"
  "Footage/A-Roll"
  "Footage/B-Roll"
  "Images"
  "Exports"
)

# Spanish folder structure
declare -a FOLDERS_es=(
  "Audio/Música"
  "Audio/Locución"
  "Audio/Efectos de sonido"
  "Metraje/A-Roll"
  "Metraje/B-Roll"
  "Imágenes"
  "Exportaciones"
)

# Associative array to map a language to the corresponding array's name
declare -A FOLDERS_MAP=(
  [en]="FOLDERS_en"
  [es]="FOLDERS_es"
)
