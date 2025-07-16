function get_name() {
  # Launch kdialog for asking for a folder name
  local -r kdialog_name=$(
    kdialog \
      --title "$(i18n kname@title)" \
      --inputbox "$(i18n kname@inputbox) $SELECTED_DIR/:" \
      --getexistingdirectory "$(i18n kname@project)" \
      --geometry 512x256
  )

  echo "$kdialog_name"
}

function new_project() {
  # Create a new project directory structure
  local -r kdialog_name=$(get_name)

  lang=$(get_lang)

  if [ -n "$kdialog_name" ]; then
    mkdir -p "$SELECTED_DIR/$kdialog_name"

    IFS=' ' read -ra folder_names <<<"${FOLDERS[$lang]}"

    for folder in "${folder_names[@]}"; do
      mkdir -p "$SELECTED_DIR/$kdialog_name/$folder"
    done

  fi
}
