#!/bin/bash

#######################################
# Ensure packages are installed.
# Globals:
#   ID
#   INSTALL_CMD
#   SUDO
# Arguments:
#   List of packages to install.
#######################################
check_packages() {
  # TODO: Check if package is installed and if so, skip it.
  # Also, we shouldn't update for each package since that will take forever.
  if [ "${INSTALL_CMD}" = "apt-get" ]; then
    if ! dpkg -s "$@" >/dev/null 2>&1; then
      pkg_mgr_update
      "${SUDO}""${INSTALL_CMD}" -y install --no-install-recommends "$@"
    fi
  elif [ "${INSTALL_CMD}" = "brew" ]; then
    pkg_mgr_update
    "${INSTALL_CMD}" install "$@"
  else
    echo "Linux distro ${ID} not supported."
    exit 1
  fi
}

#######################################
# Clean up package manager cache files.
# Globals:
#   ADJUSTED_ID
# Arguments:
#   None
#######################################
clean_up() {
  case "${ADJUSTED_ID}" in
  debian)
    rm -rf /var/lib/apt/lists/*
    ;;
  darwin)
    brew cleanup
    ;;
  esac
}

#######################################
# Update package manager.
# Globals:
#   INSTALL_CMD
#   SUDO
# Arguments:
#   None
#######################################
pkg_mgr_update() {
  if [ "${INSTALL_CMD}" = "apt-get" ]; then
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
      echo "Running apt-get update..."
      "${SUDO}""${INSTALL_CMD}" update -y
    fi
  elif [ "${INSTALL_CMD}" = "brew" ]; then
    echo "Running brew update ..."
    "${INSTALL_CMD}" update
  fi
}

