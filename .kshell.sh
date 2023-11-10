#!/bin/bash

# Copy and paste this function into your .zshrc or .bashrc to use.

# This function assumes the following:
#   1. You have fzf (https://github.com/junegunn/fzf) installed
#   2. You have kubectl installed
#   3. Your helm managed deployments contain the label 'app.kubernetes.io/instance'
#      where the value is the name of the helm release
#   4. Your active kubeconfig context is already pointing to the cluster
#      and namespace where your helm releases are installed

# Usage:
# $ kshell (reset|status)
#
# Passing "reset" as an argument will prompt you to choose a new helm release,
# deploy, etc. Otherwise, kshell will remember your previous choices and
# immediately open up a new shell prompt in your desired Kubernetes workload.

#######################################
# Opens interactive bash shell in a kubernetes deployment managed by Helm.
# Globals:
#   KSHELL_RELEASE
#   KSHELL_DEPLOY
#   KSHELL_CONTAINER
# Arguments:
#   None
#######################################
function kshell {
  if [[ (-z "$KSHELL_RELEASE" && -z "$KSHELL_DEPLOY" && -z "$KSHELL_CONTAINER") ]]; then
    configured=false
  else
    configured=true
  fi

  if [[ "$1" == "status" ]]; then
    if [[ "$configured" == true ]]; then
      echo "Helm Release: $KSHELL_RELEASE"
      echo "Deployment:   $KSHELL_DEPLOY"
      echo "Container:    $KSHELL_CONTAINER"
    else
      echo "kshell not configured yet."
    fi

    return
  fi

  if [[ "$configured" == false || ("$1" == "reset") ]]; then
    echo "Choose Helm release"
    release=$(helm list -q | fzf --height=30% --layout=reverse --border --margin=1 --padding=1)
    export KSHELL_RELEASE=$release

    echo "Choose deployment"
    deploy=$(kubectl get deploy -l "app.kubernetes.io/instance=$release" --sort-by=.metadata.creationTimestamp -o name | fzf --height=30% --layout=reverse --border --margin=1 --padding=1)
    export KSHELL_DEPLOY=$deploy

    echo "Choose container"
    containers=$(kubectl get "$deploy" -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{"\n"}{end}')
    container=$(echo "$containers" | fzf --height=30% --layout=reverse --border --margin=1 --padding=1)
    export KSHELL_CONTAINER=$container
  fi

  kubectl exec -it "$deploy" -c "$container" -- bash
}
