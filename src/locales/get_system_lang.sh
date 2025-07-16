function get_lang() {
  # Determine the language based on the LANG environment variable
  local lang=${LANG:0:2}
  local available=("es" "en")

  if [[ " ${available[*]} " == *"$lang"* ]]; then
    echo "$lang"
  else
    echo "en"
  fi
}

function i18n() {
  local action=$1
  lang=$(get_lang)
  local msg="${lang}_${action}"

  echo "${dictionary[$msg]}"
}
