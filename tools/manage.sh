#!/bin/env bash

set -o errexit -o nounset -o pipefail

# Calculate the project root path (one level above the 'tools' directory)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
readonly PROJECT_NAME="resolvetools"

# File and Directory Paths
readonly SRC_DIR="${PROJECT_ROOT}"
readonly DESKTOP_SRC_DIR="${PROJECT_ROOT}/desktop"
readonly BUILD_DIR="${PROJECT_ROOT}/build"

# Installation Paths
readonly INSTALL_KIO_DIR="$HOME/.local/share/kio/servicemenus"
readonly TARGET_SCRIPT_DIR="${INSTALL_KIO_DIR}/${PROJECT_NAME}"
readonly TARGET_DESKTOP_FILE="${INSTALL_KIO_DIR}/${PROJECT_NAME}.desktop"

# Output Colors
readonly R="\033[1;31m" G="\033[1;32m" B="\033[1;34m" Y="\033[1;33m" E="\033[0m"

# Logging Functions
function log_error() {
  printf >&2 "${R}::${E} %s\n" "$*"
  exit 1
}

function log_success() {
  printf "${G}::${E} %s\n" "$*"
}

function log_info() {
  printf "${B}::${E} %s\n" "$*"
}

function log_warn() {
  printf "${Y}::${E} %s\n" "$*"
}

# Action Functions

function action_install() {
  log_info "Starting Resolve Tools installation..."

  log_info "Creating destination directory: ${TARGET_SCRIPT_DIR}"
  mkdir -p "${TARGET_SCRIPT_DIR}"

  log_info "Copying main scripts..."
  cp "${SRC_DIR}/init.sh" "${TARGET_SCRIPT_DIR}/"
  cp -r "${SRC_DIR}/src" "${TARGET_SCRIPT_DIR}/"

  log_info "Copying and activating the .desktop service file..."
  cp "${DESKTOP_SRC_DIR}/${PROJECT_NAME}.desktop" "${TARGET_DESKTOP_FILE}"
  chmod +x "${TARGET_DESKTOP_FILE}"

  log_success "Installation complete! Resolve Tools is ready to use."
}

function action_uninstall() {
  log_info "Starting Resolve Tools uninstallation..."
  local uninstalled=false

  if [ -f "${TARGET_DESKTOP_FILE}" ]; then
    log_info "Removing .desktop file: ${TARGET_DESKTOP_FILE}"
    rm -f "${TARGET_DESKTOP_FILE}"
    uninstalled=true
  fi

  if [ -d "${TARGET_SCRIPT_DIR}" ]; then
    log_info "Removing script directory: ${TARGET_SCRIPT_DIR}"
    rm -rf "${TARGET_SCRIPT_DIR}"
    uninstalled=true
  fi

  if $uninstalled; then
    log_success "Uninstallation complete!"
  else
    log_warn "No existing installation of Resolve Tools found."
  fi
}

function action_package() {
  log_info "Creating distribution package..."

  action_clean

  local pkg_content_dir="${BUILD_DIR}/${PROJECT_NAME}"
  local pkg_file="${PROJECT_ROOT}/${PROJECT_NAME}.tar.xz"

  log_info "Creating package directory structure..."
  mkdir -p "${pkg_content_dir}"

  log_info "Copying files to package directory..."
  cp "${SRC_DIR}/init.sh" "${pkg_content_dir}/"
  cp -r "${SRC_DIR}/src" "${pkg_content_dir}/"
  cp "${SRC_DIR}/LICENSE" "${BUILD_DIR}/"
  cp "${DESKTOP_SRC_DIR}/${PROJECT_NAME}.desktop" "${BUILD_DIR}/"

  # Create a simple installation script for the package
  cat >"${BUILD_DIR}/install.sh" <<EOF
#!/bin/env bash
set -euo pipefail
echo "Installing Resolve Tools..."
INSTALL_DIR="\$HOME/.local/share/kio/servicemenus"
mkdir -p "\$INSTALL_DIR"
cp -r "./${PROJECT_NAME}" "\$INSTALL_DIR/"
cp "./${PROJECT_NAME}.desktop" "\$INSTALL_DIR/"
chmod +x "\$INSTALL_DIR/${PROJECT_NAME}.desktop"
echo "Installation complete!"
EOF
  chmod +x "${BUILD_DIR}/install.sh"

  log_info "Compressing package to ${pkg_file}..."
  (cd "${BUILD_DIR}" && tar -cJf "${pkg_file}" --transform "s|^\./||" .)

  log_success "Package created successfully at ${pkg_file}!"
  log_info "Cleaning up temporary files..."
  action_clean
}

function action_clean() {
  if [ -d "${BUILD_DIR}" ]; then
    log_info "Cleaning build directory: ${BUILD_DIR}"
    rm -rf "${BUILD_DIR}"
  fi
}

function show_usage() {
  printf "Usage: %s [command]\n" "$(basename "$0")"
  printf "Management script for Resolve Tools.\n\n"
  printf "Commands:\n"
  printf "  install    Installs the service menus on the local system.\n"
  printf "  uninstall  Removes the service menus from the system.\n"
  printf "  package    Creates a tar.xz package for distribution.\n"
}

function main() {
  if [ $# -eq 0 ]; then
    show_usage
    exit 1
  fi

  case "$1" in
  install) action_install ;;
  uninstall) action_uninstall ;;
  package) action_package ;;
  *)
    log_error "Unknown command: '$1'"
    ;;
  esac
}

main "$@"
