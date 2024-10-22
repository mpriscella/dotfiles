######## zinit (https://github.com/zdharma-continuum/zinit) integration ########

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME"/.git ] && git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit load atuinsh/atuin

##################################### brew #####################################

if [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:$PATH"

  if type "brew" >/dev/null; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

#################################### Theme #####################################

zinit load mafredri/zsh-async
zinit load sindresorhus/pure

################################################################################

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# Use vi mode with ZSH Line Editor (zle).
# See https://zsh.sourceforge.io/Guide/zshguide04.html for documentation.
bindkey -v

# (F)astly (Debug).
# Sends the Fastly-Debug header to an endpoint.
# Additional documentation: https://developer.fastly.com/reference/http/http-headers/Fastly-Debug/
alias fdebug='curl -svo /dev/null -H "Fastly-Debug: true"'
# (H)eader C(url).
alias hurl='curl -sLD - -o /dev/null'
# (T)ime (T)o (F)irst (B)yte.
alias ttfb='curl -o /dev/null -H "Cache-Control: no-cache" -s -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n"'

alias reload='source ~/.zshrc'

# Enable colored output for default commands.
# TODO should work on both darwin(mac) and linux.
alias grep='grep --color=auto '

# Need to see if this works or if we need to use ls --color=auto
# TODO should work on both darwin(mac) and linux.
if ls -G >/dev/null 2>&1; then
  alias ls='ls -G'
else
  alias ls='ls --color=always'
fi

export PATH=$HOME/.bin:$HOME/.nvim/bin:$PATH
export LANG="en_US.UTF-8"
export TERM="xterm-256color"

##################################### AWS ######################################

if (type "aws" >/dev/null && type aws_completer >/dev/null); then
  aws_completer_path=$(which aws_completer)
  complete -C "$aws_completer_path" aws

  export AWS_CLI_AUTO_PROMPT=on-partial

  if [ -z "$AWS_PROFILE" ]; then
    export AWS_PROFILE=default
  fi

  #######################################
  # Switch between AWS Profiles.
  # Arguments:
  #   None
  #######################################
  function aws-ps {
    profile=$(aws configure list-profiles | fzf --height=30% --layout=reverse)
    if [ -n "$profile" ]; then
      export AWS_PROFILE=$profile
      echo "AWS profile \"$AWS_PROFILE\" now active."
    fi
  }

  #######################################
  # Log into ECR repositories.
  # Arguments:
  #   None
  #######################################
  function ecr-login {
    if [[ $(aws sts get-caller-identity >/dev/null 2>&1) -ne 0 ]]; then
      echo "Could not connect to AWS account. Please verify that your credentials are correct."
      kill -INT $$
    fi

    region=$(aws configure get region)
    name=$(aws ecr describe-repositories --output json --query "repositories[*].repositoryName" | jq -r '.[]' | fzf --height=30% --layout=reverse --border --margin=1 --padding=1)
    uri=$(aws ecr describe-repositories --repository-names "$name" --output json --query "repositories[*].repositoryUri" | jq -r '.[]')

    echo "Logging into $uri..."
    aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$uri"
  }
fi

#################################### Editor ####################################

if type "nvim" >/dev/null; then
  export EDITOR=nvim
  export GIT_EDITOR=nvim
  export KUBE_EDITOR=nvim

  alias vi=nvim
  alias vim=nvim
else
  export EDITOR=vim
  export GIT_EDITOR=vim
  export KUBE_EDITOR=vim

  alias vi=vim
fi

############## FZF (https://github.com/junegunn/fzf) integration ###############

[ -f "$HOME"/.fzf.zsh ] && source "$HOME"/.fzf.zsh
export FZF_DEFAULT_COMMAND='find . -not -path "**/.git/**"'

################################## Kubernetes ##################################

if type "helm" >/dev/null; then
  source <(helm completion zsh)
fi

if type "kind" >/dev/null; then
  source <(kind completion zsh)
fi

if type "kubectl" >/dev/null; then
  source <(kubectl completion zsh)
fi

#################################### GitHub ####################################

if type "gh" >/dev/null; then
  source <(gh completion --shell zsh)
fi

################################### Functions ##################################

if (type "helm" >/dev/null && type "kubectl" >/dev/null); then
  [ -f "$HOME"/.kshell.sh ] && source "$HOME"/.kshell.sh
fi

############################### Load Local zshrc ###############################

# shellcheck source=/dev/null
[ -f "$HOME"/.zshrc.local ] && source "$HOME"/.zshrc.local

#######################################
# Create a visual pill.
# Arguments:
#   text
#   pill_color
#   text_color
#######################################
function create_pill {
  icon=$1
  text=$2
  pill_color=$3
  text_color=${4:-"black"}

  pill_left="%{$fg[$pill_color]%}"
  pill_right="%{$reset_color$fg[$pill_color]%}"

  pill="$pill_left%{$bg[$pill_color]$fg[$text_color]%}$icon  $text$pill_right%{$reset_color%}"
  echo $pill
}

function kube_pill {
  context=$(kubectl config view --minify -o jsonpath='{.current-context}')
  namespace=$(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}')

  echo "%{$fg[red]%}$context%{$fg[black]%}/%{$fg[white]%}$namespace"
}

gen_prompt=''
if [ -n "$AWS_PROFILE" ]; then
  gen_prompt='$(create_pill   $AWS_PROFILE "yellow")'
fi

# If shell is running in tmux, don't add kubectl context info to prompt.
if [[ "$TERM_PROGRAM" != "tmux" ]]; then
  if type "kubectl" >/dev/null && $(kubectl config current-context >/dev/null 2>&1); then
    context=$(kube_pill)
    gen_prompt="$gen_prompt $(create_pill 󱃾 $context 'blue')"
  fi
fi

export RPROMPT=$gen_prompt
