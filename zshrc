############### Zim (https://github.com/zimfw/zimfw) integration ###############

# Define zim location
export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Start zim
[[ -s ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh

############## FZF (https://github.com/junegunn/fzf) integration ###############

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey -s '^P' 'fzf^M'

################################################################################

alias reload='source ~/.zshrc'
alias vim='nvim'
alias vi='nvim'
alias fd="find . -name"

export PATH=$HOME/.bin:$PATH

################################# Docker tools #################################

DOCKER_CMD="docker run -it --rm --name"
MNT_CMD="-v $(pwd):/home/workspace -w /home/workspace"

alias alpine="$DOCKER_CMD alpine $MNT_CMD alpine sh"
alias composer="$DOCKER_CMD composer --entrypoint="" $MNT_CMD composer composer --ignore-platform-reqs"
alias golang="$DOCKER_CMD golang -v $(pwd):/go/src/${PWD##*/} -w /go/src/${PWD##*/} golang:1.12 bash"
alias kk="$DOCKER_CMD kubectl $MNT_CMD --entrypoint="" lachlanevenson/k8s-kubectl kubectl --kubeconfig=kubeconfig"
alias linux="$DOCKER_CMD linux $MNT_CMD amazonlinux sh"
alias ncdu="$DOCKER_CMD ncdu $MNT_CMD alpine sh -c 'apk add ncdu && ncdu'"
alias nginx="$DOCKER_CMD nginx -v $(pwd):/usr/share/nginx/html:ro -p 8080:80 -d nginx"
alias node="$DOCKER_CMD node $MNT_CMD node:10-alpine sh"
alias phpcontainer="$DOCKER_CMD php $MNT_CMD php bash"
alias python="$DOCKER_CMD python $MNT_CMD python bash"
alias tree="$DOCKER_CMD tree $MNT_CMD alpine sh -c 'apk add tree && tree .'"
alias ubuntu="$DOCKER_CMD ubuntu $MNT_CMD ubuntu bash"

############################### Load Local zshrc ###############################

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
