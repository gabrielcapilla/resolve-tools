#!/bin/env bash

# Simplified internationalization system
# Merged from get_dictionary.sh and get_system_lang.sh

# Translation dictionary
declare -gA I18N=(
  # Spanish translations
  [es_kprogress_progress]="Trabajando sobre"
  [es_kprogress_title]="Ejecutando"
  [es_kname_inputbox]="Crear nuevo proyecto en"
  [es_kname_project]="Nuevo Proyecto"
  [es_kname_title]="Crear carpetas de proyecto"
  [es_kname_success_title]="Operación Completada"
  [es_kname_success_msg]="El proyecto '%1' ha sido creado exitosamente."
  [es_stderr_acodec]="Códec de Audio no encontrado."
  [es_stderr_vcodec]="Códec de Vídeo no encontrado."

  # English translations (default)
  [en_kprogress_progress]="Working On"
  [en_kprogress_title]="Executing"
  [en_kname_inputbox]="Create new project in"
  [en_kname_project]="New Project"
  [en_kname_title]="Create project folders"
  [en_kname_success_title]="Operation Complete"
  [en_kname_success_msg]="Project '%1' was created successfully."
  [en_stderr_acodec]="Audio codec not detected."
  [en_stderr_vcodec]="Video codec not detected."
)

function i18n() {
  # Get translated string
  # Usage: i18n key_subkey (e.g., i18n kname_title)
  local key="${LANG:0:2}_$1"
  local default="en_$1"
  printf '%s' "${I18N[$key]:-${I18N[$default]}}"
}
