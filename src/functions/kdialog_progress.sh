function kdialog_progressbar() {
  # Display a progress bar using kdialog
  kdialog \
    --title "$(i18n kprogress@title)" \
    --progressbar "$(i18n kprogress@progress) $FILE" \
    100
}

function kdialog_cancel() {
  # Cancels the ffmpeg process when the user presses cancel
  read -r dbus_name dbus_path <<<$kprogress

  while true; do
    if ! qdbus "$dbus_name" "$dbus_path" >/dev/null 2>&1; then
      kill "$ffmpeg_pid"
      rm -f "$ktemp"
      exit 1
    fi
  done
}

function get_duration() {
  # Get the duration of a media file using ffprobe
  local duration
  duration=$(
    ffprobe \
      -v error \
      -show_entries format=duration \
      -of default=noprint_wrappers=1:nokey=1 \
      "$FILE"
  )

  echo "$duration"
}

function calculate_progress() {
  # Calculate the progress percentage of a media conversion
  local time_ms=$1
  local duration_seconds=$2
  local progress_seconds percent

  progress_seconds=$(echo "scale=2; $time_ms / 1000000" | bc)
  percent=$(echo "scale=2; (($progress_seconds / $duration_seconds) * 100) / 1" | bc)

  echo "${percent%.*}"
}

function monitor_progress() {
  # Update the progress of the ffmpeg conversion process
  local ffmpeg_pid=$1
  local duration_seconds=$2

  kdialog_cancel &

  sleep 1

  while ps -p "$ffmpeg_pid" >/dev/null; do
    if [[ -f "$ktemp" ]]; then
      local time_ms
      time_ms=$(grep -oP 'time_ms=\K\d+' "$ktemp" | tail -n 1)

      if [[ -n "$time_ms" && "$time_ms" =~ ^[0-9]+$ ]]; then
        percent=$(calculate_progress "$time_ms" "$duration_seconds")
        qdbus $kprogress Set "" value "$percent"
      fi
    fi
  done

  # Ensure the progress bar reaches 100%
  qdbus $kprogress Set "" value 100
  sleep 1
  qdbus $kprogress close
  rm -f "$ktemp"
}
