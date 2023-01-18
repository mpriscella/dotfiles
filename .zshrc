############## zplug (https://github.com/zplug/zplug) integration #############

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# If zplug isn't installed, clone it.
if [ ! -d ~/.zplug ]; then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

#################################### Theme #####################################

zplug mafredri/zsh-async, from:github
zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme

################################################################################

# Use vi mode with ZSH Line Editor (zle).
# See https://zsh.sourceforge.io/Guide/zshguide04.html for documentation.
bindkey -v

# (F)astly Debug.
alias fdebug='curl -svo /dev/null -H "Fastly-Debug: true"'
# (H)eader C(url).
alias hurl="curl -sLD - -o /dev/null"
alias reload='source ~/.zshrc'
# (T)ime (T)o (F)irst (B)yte.
alias ttfb='curl -o /dev/null -H "Cache-Control: no-cache" -s -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n"'
alias vi='vim'

# Enable colored output for default commands.
alias grep='grep --color=auto '

# Need to see if this works or if we need to use ls --color=auto
if ls -G > /dev/null 2>&1 ; then
  alias ls='ls -G'
else
  alias ls='ls --color=always'
fi

export PATH=$HOME/.bin:$PATH
export GIT_EDITOR=vim

#################################### Docker ####################################

# Only include docker specific configurations if shell is not running on a
# docker container.
# TODO Need to come up with better way of dynamically including docker aliases.
# if (( $+commands[virt-what] ))
# then
#   if [[ $(virt-what) -ne 0 ]]; then
#     source ~/.docker.aliases.zshrc
#   fi
# else
#   source ~/.docker.aliases.zshrc
# fi

############## FZF (https://github.com/junegunn/fzf) integration ###############

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey -s '^P' 'fzf^M'

################################## Kubernetes ##################################

export KUBE_EDITOR=vim
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

if (( $+commands[helm] ))
then
  source <(helm completion zsh)
fi

if (( $+commands[kind] ))
then
  source <(kind completion zsh)
fi

export RPROMPT=""
if (( $+commands[kubectl] ))
then
  source <(kubectl completion zsh)
  zplug jonmosco/kube-ps1, use:kube-ps1.sh, from:github

  export KUBE_PS1_DIVIDER="/"
  export KUBE_PS1_SYMBOL_ENABLE=false
fi

################################## 1password ###################################

if (( $+commands[op] ))
then
  eval "$(op completion zsh)"; compdef _op op
fi

#################################### github ####################################

if (( $+commands[gh] ))
then
  source <(gh completion --shell zsh)
fi

##################################### tmux #####################################

export TERM=xterm-256color

##################################### brew #####################################

if [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:$PATH"

  if (( $+commands[brew] ))
  then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

##################################### aws ######################################

if (( $+commands[aws] && $+commands[aws_completer] ))
then
  autoload bashcompinit && bashcompinit
  autoload -Uz compinit && compinit

  aws_completer_path=$(which aws_completer)
  complete -C $aws_completer_path aws

  #######################################
  # Switch between AWS Profiles.
  # Arguments:
  #   None
  #######################################
  function aws-ps {
    profile=$(aws configure list-profiles | fzf --height=30% --layout=reverse --border --margin=1 --padding=1)
    export AWS_PROFILE=$profile
  }
fi

################################### Functions ##################################

#######################################
# Install latest release of sops.
# Arguments:
#   None
#######################################
function sops_install {
  tag_name=$(curl -s https://api.github.com/repos/mozilla/sops/releases/latest | jq -r .tag_name)
  sudo curl -L https://github.com/mozilla/sops/releases/download/$tag_name/sops-$tag_name.linux -o /usr/local/bin/sops
  sudo chmod +x /usr/local/bin/sops
}

############################### Load Local zshrc ###############################

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  zplug install
fi

zplug load

if (( $+commands[kubectl] ))
then
  export RPROMPT='%{$fg[green]%}${AWS_PROFILE}%{$reset_color%}%::$(kube_ps1)'
fi

export FZF_DEFAULT_COMMAND="find ."
