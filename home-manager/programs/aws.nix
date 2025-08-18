{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.awscli = {
    enable = true;
  };

  home.sessionVariables = {
    AWS_CLI_AUTO_PROMPT = "on-partial";
  };

  programs.fish.functions.aws-ps = {
    description = "Switch AWS profiles";
    body = ''
      set -l profile $(aws configure list-profiles | fzf --height=30% --layout=reverse)
      if set --query profile
        set -gx AWS_PROFILE $profile
        echo "Switched to AWS profile: $profile"
      end
    '';
  };

  programs.fish.functions.ecr-login = {
    description = "Login to ECR";
    body = ''
      # Check if AWS credentials are valid
      if not aws sts get-caller-identity >/dev/null 2>&1
        echo "Could not connect to AWS account. Please verify that your credentials are correct."
        return
      end

      # Get AWS region
      set region (aws configure get region)

      # Select repository name using fzf
      set name (aws ecr describe-repositories --output json --query "repositories[*].repositoryName" | jq -r '.[]' | fzf --height=30% --layout=reverse --border --margin=1 --padding=1)

      # Get repository URI
      set uri (aws ecr describe-repositories --repository-names $name --output json --query "repositories[*].repositoryUri" | jq -r '.[]')

      # Log in to the repository
      echo "Logging into $uri..."
      aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $uri
    '';
  };
}
