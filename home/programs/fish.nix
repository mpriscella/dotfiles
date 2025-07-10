{ config, pkgs, lib, inputs, ... }:

{
  config = {
    # Fish shell configuration
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/fish.nix
    programs.fish = {
      enable = true;

      shellInit = ''
        # Set up direnv if available
        if command -v direnv >/dev/null
          direnv hook fish | source
        end

        fish_vi_key_bindings
      '';

      # functions = {
      #   aws-ps = {
      #     description = "Switch AWS profiles";
      #     body = ''
      #       set -l profile $(aws configure list-profiles | fzf --height=30% --layout=reverse)
      #       if set --query profile
      #         set -gx AWS_PROFILE $profile
      #         echo "Switched to AWS profile: $profile"
      #       end
      #     '';
      #   };
      #   ecr-login = {
      #     description = "Login to ECR";
      #     body = ''
      #       # Check if AWS credentials are valid
      #       if not aws sts get-caller-identity >/dev/null 2>&1
      #           echo "Could not connect to AWS account. Please verify that your credentials are correct."
      #           return
      #       end

      #       # Get AWS region
      #       set region (aws configure get region)

      #       # Select repository name using fzf
      #       set name (aws ecr describe-repositories --output json --query "repositories[*].repositoryName" | jq -r '.[]' | fzf --height=30% --layout=reverse --border --margin=1 --padding=1)

      #       # Get repository URI
      #       set uri (aws ecr describe-repositories --repository-names $name --output json --query "repositories[*].repositoryUri" | jq -r '.[]')

      #       # Log in to the repository
      #       echo "Logging into $uri..."
      #       aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $uri
      #     '';
      #   };
      # };

      shellAliases = {
        # Modern replacements
        cat = "bat --style=plain";
        find = "fd";
        grep = "rg";

        lg = "lazygit";
      };

      plugins = [
        {
          name = "pure";
          src = pkgs.fishPlugins.pure.src;
        }
      ];
    };


  };
}
