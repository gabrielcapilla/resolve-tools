#!/bin/env bash

# Unified KDialog interface - replaces 4 separate files
# Handles: error dialogs, debug messages, progress bars, input dialogs

function get_qdbus_cmd() {
  # Detect available qdbus command (Qt5 or Qt6)
  if command -v qdbus &>/dev/null; then
    echo "qdbus"
  elif command -v qdbus6 &>/dev/null; then
    echo "qdbus6"
  elif command -v qdbus-qt5 &>/dev/null; then
    echo "qdbus-qt5"
  else
    echo ""
  fi
}

function kdialog_error() {
  # Show error dialog and exit
  local -r msg="Error: $*"
  kdialog --error "$msg" --title "Resolve Tools Error" --icon "error"
  exit 1
}

# Backward compatibility alias
function stderr() { kdialog_error "$@"; }

function kdialog_debug() {
  # Show debug message
  kdialog --msgbox "Debug: $*" --title "Resolve Tools Debug"
}

function kdialog_input() {
  # Show input dialog
  local -r title="$1" text="$2" default="$3"
  kdialog --title "$title" --inputbox "$text" "$default"
}

function kdialog_progress() {
  # Show progress bar dialog
  local -r title="$1" text="$2"
  kdialog --title "$title" --progressbar "$text" 100
}

function monitor_progress() {
  # Monitor ffmpeg progress and update dialog
  # Arguments: ffmpeg_pid duration_seconds kdialog_bus temp_file
  local -r pid="$1" duration="$2" bus="$3" temp="$4"
  local -r qdbus=$(get_qdbus_cmd)

  # Fallback: no qdbus available
  if [[ -z "$qdbus" ]]; then
    wait "$pid"
    rm -f "$temp"
    return 0
  fi

  # Start cancel watcher in background
  watch_cancel "$bus" "$pid" "$temp" "$qdbus" &
  local -r watcher=$!

  sleep 1

  # Monitor progress
  while ps -p "$pid" >/dev/null 2>&1; do
    if [[ -f "$temp" ]]; then
      local time_us
      time_us=$(grep -oP 'out_time_us=\K\d+' "$temp" 2>/dev/null | tail -n 1)
      if [[ -n "$time_us" && "$time_us" =~ ^[0-9]+$ ]]; then
        local percent
        percent=$(awk -v t="$time_us" -v d="$duration" 'BEGIN {
          if (d == 0) { print 100; exit }
          p = (t / 1000000 / d) * 100
          printf "%.0f\n", (p > 100 ? 100 : p)
        }')
        "$qdbus" $bus Set "" value "$percent" 2>/dev/null || true
      fi
    fi
    sleep 0.5
  done

  # Cleanup
  kill "$watcher" 2>/dev/null || true
  "$qdbus" $bus Set "" value 100 2>/dev/null || true
  sleep 0.2
  "$qdbus" $bus close 2>/dev/null || true
  rm -f "$temp"
}

function watch_cancel() {
  # Watch for dialog cancellation
  # Arguments: bus_name ffmpeg_pid temp_file qdbus_cmd
  local -r bus="$1" pid="$2" temp="$3" qdbus="$4"
  local dbus_name dbus_path
  read -r dbus_name dbus_path <<<"$bus"

  while true; do
    if ! "$qdbus" "$dbus_name" "$dbus_path" >/dev/null 2>&1; then
      kill "$pid" 2>/dev/null || true
      rm -f "$temp"
      exit 1
    fi
    sleep 1
  done
}
