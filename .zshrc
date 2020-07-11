############## zplug (https://github.com/zplug/zplug) integration #############

# If zplug isn't installed, clone it.
if [[ ! -d ~/.zplug ]];then
    git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  # printf "Install? [y/N]: "
  # if read -q; then
  echo; zplug install
  # fi
fi

#################################### Theme #####################################

zplug mafredri/zsh-async, from:github
zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme

################################################################################

bindkey -v

# bindkey -M vicmd u vi-kill-line
# bindkey -M viins "^U" vi-kill-line

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

MNT_DIR="/home/workspace"

# Enable BuildKit Docker build architecture.
# https://docs.docker.com/develop/develop-images/build_enhancements/
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

alias alpine='docker run -it --rm --name alpine -v $(pwd):$MNT_DIR -w $MNT_DIR alpine sh'
alias awscli='docker run -it --rm --name awscli -v $HOME/.aws:/ansible/.aws -v $(pwd):$MNT_DIR -w $MNT_DIR groupninemedia/awscli bash'
alias composer='docker run -it --rm --name composer -v $(pwd):$MNT_DIR -w $MNT_DIR composer --ignore-platform-reqs'
alias amazonlinux='docker run -it --rm --name linux -v $(pwd)/:$MNT_DIR -w $MNT_DIR amazonlinux sh'
alias halyard='docker run -p 8084:8084 -p 9000:9000 --name halyard --rm -v ~/.hal:/home/spinnaker/.hal -d gcr.io/spinnaker-marketplace/halyard:stable'
alias k6='docker run loadimpact/k6'
alias ncdu='docker run -it --rm --name ncdu -v $(pwd):$MNT_DIR -w $MNT_DIR alpine sh -c "apk add ncdu && ncdu ."'
alias nginx='docker run -it --rm --name nginx -v $(pwd):/usr/share/nginx/html:ro -p 8080:80 -d nginx'
alias node='docker run -it --rm --name node -v $(pwd):$MNT_DIR -w $MNT_DIR node:10-alpine sh'
alias phpcontainer='docker run -it --rm --name php -v $(pwd):$MNT_DIR -w $MNT_DIR php bash'
alias python='docker run -it --rm --name python -v $(pwd):$MNT_DIR -w $MNT_DIR python bash'
alias shellcheck='docker run --rm -v $(PWD):/mnt koalaman/shellcheck:stable'
alias ssh-reg='docker run -it --rm --name ssh-reg -v $HOME/.ssh/config:/root/.ssh/config -e COLUMNS="`tput cols`" -e LINES="`tput lines`" docker.pkg.github.com/mpriscella/ssh-reg/ssh-reg:1.1.1'
alias tree='docker run -it --rm --name tree -v $(pwd):$MNT_DIR -w $MNT_DIR mpriscella/tree'
alias ubuntu='docker run -it --rm --name ubuntu -v $(pwd):$MNT_DIR -w $MNT_DIR ubuntu bash'
alias wget='docker run -it --rm --name wget -v $(pwd):$MNT_DIR -w $MNT_DIR mpriscella/wget'

############## FZF (https://github.com/junegunn/fzf) integration ###############

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey -s '^P' 'fzf^M'

###################################### Go ######################################

export PATH=$HOME/go/bin:$PATH

alias golang='docker run -it --rm --name golang -v $(pwd):/go/src/${PWD##*/} -w /go/src/${PWD##*/} golang:1.13 bash'

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

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export TERM=xterm-256color

############################### Load Local zshrc ###############################

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

zplug load
