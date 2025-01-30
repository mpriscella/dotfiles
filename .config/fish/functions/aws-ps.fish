#######################################
# Switch between AWS Profiles.
# Arguments:
#   None
#######################################
function aws-ps
  # TODO There should be a "clear profile" option which unsets AWS_PROFILE.

  # Need to check profile if it's empty, not sure if this does that or not.
  set profile $(aws configure list-profiles | fzf --height=30% --layout=reverse)
  if set --query profile
    set -gx AWS_PROFILE $profile
    echo "AWS profile $AWS_PROFILE now active."
  end
end
