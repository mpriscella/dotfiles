############## zplug (https://github.com/zplug/zplug) integration #############

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# If zplug isn't installed, clone it.
if [[ ! -d ~/.zplug ]];then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

#################################### Theme #####################################

zplug mafredri/zsh-async, from:github
zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme

################################################################################

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
if (( $+commands[virt-what] ))
then
  if [[ $(virt-what) -ne 0 ]]; then
    source ~/.docker.aliases.zshrc
  fi
else
  source ~/.docker.aliases.zshrc
fi

############## FZF (https://github.com/junegunn/fzf) integration ###############

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey -s '^P' 'fzf^M'

###################################### Go ######################################

# alias golang='docker run -it --rm --name golang -v $(pwd):/go/src/${PWD##*/} -w /go/src/${PWD##*/} golang:1.13 bash'

################################## Kubernetes ##################################

export KUBE_EDITOR=vim
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export RPROMPT=""
if (( $+commands[kubectl] ))
then
  source <(kubectl completion zsh)
  zplug jonmosco/kube-ps1, use:kube-ps1.sh, from:github

  export KUBE_PS1_DIVIDER="/"
  export KUBE_PS1_SYMBOL_ENABLE=false
fi

if (( $+commands[minikube] ))
then
  source <(minikube completion zsh)
fi

if (( $+commands[helm] ))
then
  source <(helm completion zsh)
fi

if (( $+commands[kops] ))
then
  source <(kops completion zsh)
fi

if (( $+commands[gh] ))
then
  source <(gh completion --shell zsh)
fi

##################################### tmux #####################################

export TERM=xterm-256color

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

zplug load

if (( $+commands[kubectl] ))
then
  export RPROMPT='$(kube_ps1)'
fi
