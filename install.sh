#!bin/bash

# TODO
#  - Why isn't tmux.conf getting copied over?
#  - Uninstall functionality
#  - Instead of copying bin over to ~/.bin, symlink all files in bin to ~/.bin

shell="fish"
guerrilla=false
force=false
supported_shells=(fish bash)

declare -A map
mkdir -p $HOME/.config/backup

function usage {
  echo "Usage:"
  echo "  install.sh"
  echo "  install.sh -g | --guerrilla"
  echo "  install.sh -f | --force"
  echo "  install.sh -s <shell> | --shell=<shell>"
  echo " "
  echo "Options:"
  echo "  -h --help                      Display Usage."
  echo "  -g --guerrilla                 Install barebone dotfiles."
  echo "  -f --force                     Overwrite files."
  echo "  -s <shell>, --shell=<shell>    Set shell (bash and fish are supported. fish is default)."
  exit 1
}

function validate_shell {
  if [[ ! "${supported_shells[@]}" =~ ${shell} ]]; then
    printf "ERROR: shell \"%s\" is not supported." "$shell" >&2
    usage
  fi
}

function install {
  map["tmux.conf"]=".tmux.conf"
  if $guerrilla; then
    map["guerrilla-vimrc"]=".vimrc"
  else
    map["ackrc"]=".ackrc"
    map["nvimrc"]=".config/nvim/init.vim"
    map["gitconfig"]=".gitconfig"
    map["bin"]=".bin"
  fi

  if [[ "$shell" = "fish" ]]; then
    map["fish/config.fish"]=".config/fish/config.fish"
    map["fish/aliases.fish"]=".config/fish/aliases.fish"
    map["fish/gus_dont_be_lines"]=".config/fish/gus_dont_be_lines"
  elif [[ "$shell" = "bash" ]]; then
    map["bashrc"]=".bashrc"
  fi

  for i in "${!map[@]}"
  do
    if [[ -f "$HOME/${map[$i]}" ]]; then
      if [[ ! $force ]]; then
        read -r -p "Overwrite ${map[$i]}? [y/n/a/q] " response
        response=${response,,}
        if [[ $response =~ ^(yes|y)$ ]]; then
          copy_file $i ${map[$i]}
        elif [[ $response =~ ^(all|a) ]]; then
          force=true
        elif [[ $response =~ ^(quit|q) ]]; then
          exit 1
        fi
      else
        copy_file $i ${map[$i]}
      fi
    fi
  done
}

function uninstall {
  files=(~/.config/backup/*)
}

function copy_file {
  mv $HOME/$2 $HOME/.config/backup/"$1".bkup
  ln -sf $PWD/$1 $HOME/$2
}

while :; do
  case $1 in
    -g|--guerrilla)
        guerrilla=true
        shell="bash"
      ;;
    -s|--shell)
      if [ -n "$2" ]; then
        shell=$2
        validate_shell
        shift 2
        continue
      else
        printf 'ERROR: "--shell" requires a non-empty option argument.' >&2
        usage
      fi
      ;;
    --shell=?*)
        shell=${1#*=}
        validate_shell
      ;;
    --shell=)
        printf 'ERROR: "--shell" requires a non-empty option argument.' >&2
        usage
      ;;
    -f|--force)
        force=true
      ;;
    --uninstall)
        uninstall
      ;;
    *)
        install
      break
  esac
  shift
done
