############## zplug (https://github.com/zplug/zplug) integration #############

export LANG=en_US.UTF-8

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

alias fd="find . -name"
alias fdebug='curl -svo /dev/null -H "Fastly-Debug: true"'
alias hurl="curl -sLD - -o /dev/null"
alias lr='ranger'
alias reload='source ~/.zshrc'
alias ttfb='curl -o /dev/null -H "Cache-Control: no-cache" -s -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n"'

# Enable colored output for default commands.
alias grep='grep --color=auto '
alias ls='ls -G'

export PATH=$HOME/.bin:$PATH

#################################### Docker ####################################

# Only include docker specific configurations if shell is not running on a
# docker container.
if [[ -f /proc/1/sched && $(cat /proc/1/sched | head -n 1 | grep init) ]]; then
  source ~/.docker.aliases.zshrc
fi

############## FZF (https://github.com/junegunn/fzf) integration ###############

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey -s '^P' 'fzf^M'

###################################### Go ######################################

# export PATH=$HOME/go/bin:$PATH

# alias golang='docker run -it --rm --name golang -v $(pwd):/go/src/${PWD##*/} -w /go/src/${PWD##*/} golang:1.13 bash'

################################## Kubernetes ##################################

export KUBE_EDITOR=vim
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

if (( $+commands[kubectl] ))
then
  source <(kubectl completion zsh)
  zplug jonmosco/kube-ps1, use:kube-ps1.sh, from:github

  export KUBE_PS1_DIVIDER='/'
  export KUBE_PS1_SYMBOL_ENABLE=false
  export RPROMPT='$(kube_ps1)'
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

if (( $+commands[skaffold] ))
then
  source <(skaffold completion zsh)
fi

##################################### tmux #####################################

export TERM=xterm-256color

############################### Load Local zshrc ###############################

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

zplug load
