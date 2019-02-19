#
# User configuration sourced by interactive shells
#

# Define zim location
export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Start zim
[[ -s ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh

alias g9='cd ~/workspace/groupninemedia'
alias tl='cd ~/workspace/Thrillist'
alias drupal='cd ~/workspace/drupal/drupal-core'
#alias vim='nvim'
#alias vi='nvim'

alias reload='source ~/.zshrc'

# Docker containers
alias python='docker run -it --rm --name python -v $(pwd):/home/workspace -w /home/workspace python bash'
alias golang='docker run -it --rm --name golang -v $(pwd):/go/src/${PWD##*/} -w /go/src/${PWD##*/} golang:1.11 bash'
alias node='docker run -it --rm --name node -v $(pwd):/home/workspace -w /home/workspace node:10-alpine sh'
alias linux='docker run -it --rm --name linux -v $(pwd):/home/workspace -w /home/workspace amazonlinux sh'
alias nginx='docker run -it --rm --name nginx -v $(pwd):/usr/share/nginx/html:ro -p 8080:80 -d nginx'
alias network-utils='docker run -it --rm --name network-utils amouat/network-utils bash'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH=$HOME/.bin:$PATH
