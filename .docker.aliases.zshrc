#################################### Docker ####################################

MNT_DIR="/home/workspace"

# Enable BuildKit Docker build architecture.
# https://docs.docker.com/develop/develop-images/build_enhancements/
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

alias alpine='docker run -it --rm --name alpine -v $(pwd):$MNT_DIR -w $MNT_DIR alpine sh'
alias awscli='docker run -it --rm --name awscli -v $HOME/.aws:/ansible/.aws -v $(pwd):$MNT_DIR -w $MNT_DIR groupninemedia/awscli bash'
alias composer='docker run -it --rm --name composer -v $(pwd):$MNT_DIR -w $MNT_DIR composer:1.10.12 --ignore-platform-reqs'
alias amazonlinux='docker run -it --rm --name linux -v $(pwd)/:$MNT_DIR -w $MNT_DIR amazonlinux sh'
alias gcloud-auth='docker run -it --name gcloud-config gcr.io/google.com/cloudsdktool/cloud-sdk gcloud auth login'
alias gcloud='docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/cloud-sdk gcloud'
alias halyard='docker run -p 8084:8084 -p 9000:9000 --name halyard --rm -v ~/.hal:/home/spinnaker/.hal -d gcr.io/spinnaker-marketplace/halyard:stable'
alias k6='docker run loadimpact/k6'
alias ncdu='docker run -it --rm --name ncdu -v $(pwd):$MNT_DIR -w $MNT_DIR alpine sh -c "apk add ncdu && ncdu ."'
alias nginx='docker run -it --rm --name nginx -v $(pwd):/usr/share/nginx/html:ro -p 8080:80 -d nginx'
alias node='docker run -it --rm --name node -v $(pwd):$MNT_DIR -w $MNT_DIR node:10-alpine sh'
alias phpcontainer='docker run -it --rm --name php -v $(pwd):$MNT_DIR -w $MNT_DIR php bash'
alias python='docker run -it --rm --name python -v $(pwd):$MNT_DIR -w $MNT_DIR python bash'
alias shellcheck='docker run --rm -v $(PWD):/mnt koalaman/shellcheck:stable'
alias ssh-reg='docker run -it --rm --name ssh-reg -v $HOME/.ssh/config:/root/.ssh/config -e COLUMNS="`tput cols`" -e LINES="`tput lines`" docker.pkg.github.com/mpriscella/ssh-reg/ssh-reg:1.1.1'
alias tldr='docker run -it --rm --name tldr -v tldr:/root/.tldr mpriscella/tldr -t base16'
alias tree='docker run -it --rm --name tree -v $(pwd):$MNT_DIR -w $MNT_DIR mpriscella/tree'
alias ubuntu='docker run -it --rm --name ubuntu -v $(pwd):$MNT_DIR -w $MNT_DIR ubuntu bash'
alias wget='docker run -it --rm --name wget -v $(pwd):$MNT_DIR -w $MNT_DIR mpriscella/wget'
