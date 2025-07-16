function log_debug() {
  # Log a debug message
  local -r debug_message="Debug: $*"

  # Show the message box using kdialog
  kdialog --msgbox "$debug_message" \
    --title "Resolve Tools Debug"
}
