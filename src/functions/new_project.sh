function new_project() {
  local -r base_dir="$1"

  # Get project name from user
  local name
  name=$(kdialog_input "$(i18n kname_title)" "$(i18n kname_inputbox) $base_dir/" "$(i18n kname_project)")
  [[ -z "$name" ]] && return 0

  # Create folder structure (avoid subshell issues with process substitution)
  local folders
  folders=$(get_folders)
  while IFS= read -r folder; do
    [[ -n "$folder" ]] && mkdir -p "$base_dir/$name/$folder"
  done <<<"$folders"
}
