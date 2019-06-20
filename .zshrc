############### Zim (https://github.com/zimfw/zimfw) integration ###############

# Define zim location
export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Start zim
[[ -s ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh

############## FZF (https://github.com/junegunn/fzf) integration ###############

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey -s '^P' 'fzf^M'

################################################################################

export IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
START_XQUARTZ="open -a XQuartz; xhost + $IP;"

alias reload='source ~/.zshrc'
alias vim='nvim'
alias vi='nvim'
alias fd="find . -name"
alias hurl="curl -sLD - -o /dev/null"

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

alias pubip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1'"
alias ips="sudo ifconfig -a | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Always enable colored `grep` output
alias grep='grep --color=auto '

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # OS X `ls`
	colorflag="-G"
fi

# Always use color output for `ls`
alias ls="command ls ${colorflag}"
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

export PATH=$HOME/.bin:$PATH

################################# Docker tools #################################

MNT_DIR="/home/workspace"

alias alpine='docker run -it --rm --name alpine -v $(pwd):$MNT_DIR -w $MNT_DIR alpine sh'
alias composer='docker run -it --rm --name composer -v $(pwd):$MNT_DIR -w $MNT_DIR composer --ignore-platform-reqs'
alias firefox='open -a XQuartz; xhost + $IP; docker rm firefox; docker run -d --name firefox -e DISPLAY=$IP:0 -v /tmp/.X11-unix:/tmp/.X11-unix jess/firefox'
#alias golang='docker run -it --rm --name golang -v $(pwd):/go/src/${PWD##*/} -w /go/src/${PWD##*/} golang:1.12 bash'
alias golang='docker run -it --rm --name golang -v $(pwd):/home/workspace -w /home/workspace golang:1.12 bash'
alias irc='docker run --detach --name thelounge --publish 9000:9000 --volume ~/.thelounge:/var/opt/thelounge --restart always thelounge/thelounge:latest; open -a "Google Chrome" http://localhost:9000'
alias irssi='docker run -it -v $HOME/.irssi:/home/user/.irssi --read-only --name irssi jess/irssi'
alias kk="docker run -it --rm --name kubectl -v $(pwd):$MNT_DIR -w $MNT_DIR lachlanevenson/k8s-kubectl --kubeconfig=kubeconfig"
alias linux='docker run -it --rm --name linux -v $(pwd):$MNT_DIR -w $MNT_DIR amazonlinux sh'
alias ncdu='docker run -it --rm --name ncdu -v $(pwd):$MNT_DIR -w $MNT_DIR alpine sh -c "apk add ncdu && ncdu ."'
alias nginx='docker run -it --rm --name nginx -v $(pwd):/usr/share/nginx/html:ro -p 8080:80 -d nginx'
alias node='docker run -it --rm --name node -v $(pwd):$MNT_DIR -w $MNT_DIR node:10-alpine sh'
alias phpcontainer='docker run -it --rm --name php -v $(pwd):$MNT_DIR -w $MNT_DIR php bash'
alias python='docker run -it --rm --name python -v $(pwd):$MNT_DIR -w $MNT_DIR python bash'
alias ssh-reg='docker run -it --rm --name ssh-reg -v $HOME/.ssh/config:/root/.ssh/config -e COLUMNS="`tput cols`" -e LINES="`tput lines`" mpriscella/ssh-reg'
alias tree='docker run -it --rm --name tree -v $(pwd):$MNT_DIR -w $MNT_DIR mpriscella/tree'
alias ubuntu='docker run -it --rm --name ubuntu -v $(pwd):$MNT_DIR -w $MNT_DIR ubuntu bash'
alias wget='docker run -it --rm --name wget -v $(pwd):$MNT_DIR -w $MNT_DIR mpriscella/wget'

############################### Load Local zshrc ###############################

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
