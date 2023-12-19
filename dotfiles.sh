#!/bin/bash

function usage() {
	echo "Manages mpriscella/dotfiles."
	echo ""
	echo "Usage:"
	echo "  ./dotfiles.sh [command]"
	echo ""
	echo "Available Commands:"
	echo "  clean    Cleans any backup files generated from the install command."
	echo "  install  Installs dotfiles and predefined packages."
	echo ""
}

files=".ackrc .dotfiles.gitconfig .gitattributes .tmux.conf .vimrc .zshrc"

function install_dotfiles() {
	# shellcheck source=src/functions.sh
	source src/functions.sh

	case $(uname -s) in
	"Linux")
		if command -v apt >/dev/null 2>&1; then
			packages=(
				ack
				curl
				exuberant-ctags
				gawk
				git
				jq
				locales
				neovim
				python3
				tar
				tmux
				vim
				virt-what
				zsh
			)

			if [[ -n "$DESKTOP_SESSION" ]]; then
				if ! command -v docker >/dev/null 2>&1; then
					# Add dockers gpg key.
					sudo apt-get update
					sudo apt-get -y install ca-certificates curl gnupg
					sudo install -m 0755 -d /etc/apt/keyrings
					curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
					sudo chmod a+r /etc/apt/keyrings/docker.gpg

					# Add the repository to Apt sources:
					echo \
						"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
						sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
					sudo apt-get update

					sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

					if [[ -z "$USER" ]]; then
						sudo usermod -aG docker "$USER"
						newgrp docker
					fi
				fi
			fi

			if ! command -v gh >/dev/null 2>&1; then
				type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
				curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
					sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
					echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
					sudo apt update &&
					sudo apt install gh -y
			fi

			# If DESKTOP_SESSION env var exists, we're on desktop. Check to see if
			# `docker` exists and install otherwise
			PACKAGE_MANAGER="apt" install_packages "${packages[@]}"
		fi

		if command -v yum >/dev/null 2>&1; then
			packages=(
				git
				jq
				tar
				util-linux-user
				vim
				zsh
				virt-what
			)
			PACKAGE_MANAGER="yum" install_packages "${packages[@]}"
		fi

		# if command -v apk > /dev/null 2>&1; then
		#   apk add bash curl git jq ncurses perl vim zsh virt-what
		# fi

		;;
	"Darwin")
		if ! command -v brew >/dev/null 2>&1; then
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		fi

		# if ! command -v git-credential-manager-core > /dev/null 2>&1; then
		#   brew install tmux shellcheck dive gh helm yq linkerd step jq derailed/k9s/k9s
		#   brew install --cask 1password/tap/1password-cli
		# fi
		;;
	*)
		echo "Operating System '$OS' not supported."
		;;
	esac

	for i in $files; do
		if [ "$(readlink "$HOME"/"$i")" != "$PWD"/"$i" ]; then
			rm "$HOME"/"$i"
		elif test -f "$HOME"/"$i"; then
			mv "$HOME"/"$i" "$HOME"/"$i".bkup
		fi

		ln -s "$PWD"/"$i" "$HOME"/"$i"
	done

	vim +PlugInstall +qall

	# If neovim is installed, symlink vimrc to ~/.config/nvim/init.vim
	if command -v nvim &>/dev/null; then
		if [ ! -d "$HOME/.config/nvim" ]; then
			mkdir -p "$HOME/.config/nvim"
		fi
		ln -s "$PWD"/.vimrc "$HOME/.config/nvim/init.vim"
		nvim +PlugInstall +qall
	fi

	git config --global include.path "$HOME"/.dotfiles.gitconfig
}

case "$1" in
"install")
	install_dotfiles
	;;
"clean")
	for i in $files; do
		if test -f "$HOME"/"$i".bkup; then
			rm "$HOME"/"$i".bkup
		fi
	done
	;;
*)
	usage
	;;
esac
