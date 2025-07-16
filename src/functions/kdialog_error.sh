function stderr() {
  # Log an error message and exit with a non-zero status
  local -r error_message="$*"

  # Show the error box using kdialog
  kdialog --error "$error_message" \
    --title "Resolve Tools Error"

  exit 1
}
