function get_name() {
  local -r base_dir="$1"
  # Launch kdialog to ask for a new project name.
  kdialog \
    --title "$(i18n kname@title)" \
    --inputbox "$(i18n kname@inputbox) $base_dir/" \
    "$(i18n kname@project)"
}

function new_project() {
  local -r selected_dir="$1"
  # Create a new project directory structure.
  local project_name
  project_name=$(get_name "$selected_dir")

  # Exit if the user cancelled the dialog (project_name is empty)
  if [[ -z "$project_name" ]]; then
    return 0
  fi

  local lang
  lang=$(get_lang)

  # Get the name of the array for the selected language (e.g., "FOLDERS_en")
  local -r folder_array_name="${FOLDERS_MAP[$lang]}"

  # Create a name reference to the actual language-specific array
  local -n folder_list="$folder_array_name"

  # Create all project subdirectories
  for folder in "${folder_list[@]}"; do
    mkdir -p "$selected_dir/$project_name/$folder"
  done

  # (debug) Show success message
  # local success_msg
  # success_msg=$(i18n kname@success_msg)
  # kdialog --msgbox "${success_msg//%1/$project_name}" --title "$(i18n kname@success_title)"
}
