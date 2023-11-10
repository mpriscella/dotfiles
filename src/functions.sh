#!/bin/bash

#######################################
# Check to see if a package is installed or not.
# Globals:
#   PACKAGE_SEARCH
# Arguments:
#   A package name.
# Returns:
#   0 if package is installed, 1 otherwise.
#######################################
function package_is_installed() {
  package_name="$1"
  package_output=$(eval "$PACKAGE_SEARCH" "$package_name" 2>/dev/null)
  if [ "$package_output" == "" ]; then
    false
  else
    true
  fi
}

#######################################
# Install packages.
# Globals:
#   INSTALL_PACKAGE
#   UPDATE_PACKAGES
# Arguments:
#   A string array of package names.
#######################################
function install_packages() {
  prepare_package_manager
  packages=("$@")

  declare packages_to_install
  for i in "${packages[@]}"; do
    if ! package_is_installed "$i"; then
      echo "Package $i not installed..."
      packages_to_install+=("$i")
    fi
  done

  if [ ${#packages_to_install[@]} -gt 0 ]; then
    eval "$UPDATE_PACKAGES"

    for i in "${packages_to_install[@]}"; do
      echo "Installing $i..."
      eval "$INSTALL_PACKAGE $i"
    done
    echo "All packages installed."
  else
    echo "No new packages to install."
  fi
}

#######################################
# Prepare package manager specific commands.
# Globals:
#   INSTALL_PACKAGE
#   PACKAGE_MANAGER
#   PACKAGE_SEARCH
#   UPDATE_PACKAGES
#######################################
function prepare_package_manager() {
  case "$PACKAGE_MANAGER" in
  "apt")
    SUDO=""
    if command -v sudo &>/dev/null; then
      SUDO="sudo"
    fi

    INSTALL_PACKAGE="$SUDO apt-get install -y"
    PACKAGE_SEARCH="$SUDO apt -qq list --installed"
    UPDATE_PACKAGES="$SUDO apt-get update -y"
    ;;
  "yum")
    INSTALL_PACKAGE="yum install -y"
    PACKAGE_SEARCH="apt -qq list --installed"
    UPDATE_PACKAGES="yum update"
    ;;
  "apk")
    INSTALL_PACKAGE="yum install -y"
    PACKAGE_SEARCH="apt -qq list --installed"
    UPDATE_PACKAGES="yum update"
    ;;
  *)
    echo "Package Manager '$PACKAGE_MANAGER' not supported."
    exit 1
    ;;
  esac
}
