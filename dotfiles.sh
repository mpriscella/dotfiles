#!/bin/bash

# User defined configs.
ENABLE_TMUX=FALSE

SUDO=""
if type sudo >/dev/null 2>&1; then
  SUDO="sudo "
  sudo -v
  while true; do sudo -v; sleep 60; done &
fi

. functions.sh

# Bring in ID and ID_LIKE, if the file exists.
if [ -f /etc/os-release ]; then
  # shellcheck source=/dev/null
  source /etc/os-release
fi

# Normalize the OS ID.
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
  ADJUSTED_ID="debian"
elif [ "$(uname -s)" = "Darwin" ]; then
  ADJUSTED_ID="darwin"
fi

ARCHITECTURE="$(uname -m)"

if [ "${ADJUSTED_ID}" = "darwin" ]; then
  install_homebrew
fi

# Determine what the package manager install command for the OS is.
if type apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  INSTALL_CMD=apt-get
elif type brew >/dev/null 2>&1; then
  INSTALL_CMD=brew
else
  echo "(Error) Unable to find a supported package manager."
  exit 1
fi

case "$1" in
"install")
  install_dependencies
  echo "✅ Dependencies installed."

  install_dotfiles
  echo "✅ Dotfiles installed."
  echo "Opening fish shell..."

  # Open a fish shell and, when the shell exits, kill the shell that the
  # script executed in.
  fish && kill -9 $PPID
  # TODO: Maybe there's a way to restart the current application?
  # Maybe an automator script
  ;;
*)
  usage
  ;;
esac

trap 'kill %1' EXIT
