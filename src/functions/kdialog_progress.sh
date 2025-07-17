function kdialog_progressbar() {
  local -r progress_text="$1"
  # Display a progress bar using kdialog
  kdialog \
    --title "$(i18n kprogress@title)" \
    --progressbar "$progress_text" \
    100
}

function kdialog_cancel() {
  local -r kprogress_bus="$1"
  local -r ffmpeg_pid_to_kill="$2"
  local -r temp_file_to_clean="$3"

  # Cancels the ffmpeg process when the user presses cancel
  read -r dbus_name dbus_path <<<$kprogress_bus

  while true; do
    if ! qdbus "$dbus_name" "$dbus_path" >/dev/null 2>&1; then
      kill "$ffmpeg_pid_to_kill" &>/dev/null || true
      rm -f "$temp_file_to_clean"
      exit 1
    fi
    sleep 1
  done
}

function monitor_progress() {
  local -r ffmpeg_pid="$1"
  local -r duration_seconds="$2"
  local -r kprogress_bus="$3"
  local -r ktemp_file="$4"

  kdialog_cancel "$kprogress_bus" "$ffmpeg_pid" "$ktemp_file" &
  local -r cancel_watcher_pid=$!

  sleep 1

  while ps -p "$ffmpeg_pid" >/dev/null; do
    if [[ -f "$ktemp_file" ]]; then
      local time_us
      time_us=$(grep -oP 'out_time_us=\K\d+' "$ktemp_file" | tail -n 1)

      if [[ -n "$time_us" && "$time_us" =~ ^[0-9]+$ ]]; then
        percent=$(calculate_progress "$time_us" "$duration_seconds")
        qdbus $kprogress_bus Set "" value "$percent"
      fi
    fi
    sleep 0.5
  done

  kill "$cancel_watcher_pid" &>/dev/null || true

  qdbus $kprogress_bus Set "" value 100

  sleep 0.2

  qdbus $kprogress_bus close

  rm -f "$ktemp_file"
}
