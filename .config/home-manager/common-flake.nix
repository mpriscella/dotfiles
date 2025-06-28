{ config, pkgs, lib, inputs, ... }:

let
  # Get GPG signing key from host configuration, with fallback
  gpgSigningKey = config.myConfig.gpgSigningKey or null;
in

{
  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.ack
    pkgs.act
    pkgs.awscli2
    pkgs.bat
    pkgs.cf-terraforming # Shouldn't be in base config
    pkgs.dive
    pkgs.fd
    pkgs.fzf
    pkgs.gnupg
    pkgs.graphviz
    pkgs.jq
    pkgs.kind
    pkgs.k9s
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.lazydocker
    pkgs.neovim
    pkgs.nodejs_24
    pkgs.pinentry-curses
    pkgs.ripgrep
    pkgs.terraform
    pkgs.terraform-docs
    pkgs.tmux
    pkgs.yq
    pkgs.yt-dlp
  ];

  home.file = {
    ".ackrc".text = ''
      --pager=less -R
      --ignore-case
    '';

    ".tmux.conf".source = ../../tmux.conf;

    ".config/atuin".source = ../atuin;
    ".config/ghostty".source = ../ghostty;
    ".config/k9s".source = ../k9s;
    ".config/nvim".source = ../nvim;
  };

  # Common session variables
  home.sessionVariables = {
    AWS_CLI_AUTO_PROMPT = "on-partial";
    EDITOR = "nvim";
    PAGER = "less";
    LESS = "-R";
  };

  # Direnv integration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Fish shell configuration
  # https://nixos.wiki/wiki/Fish
  programs.fish = {
    enable = true;

    shellInit = ''
      # Set up direnv if available
      if command -v direnv >/dev/null
        direnv hook fish | source
      end

      fish_vi_key_bindings
    '';

    functions = {
      aws-ps = {
        description = "Switch AWS profiles";
        body = ''
          set -l profile $(aws configure list-profiles | fzf --height=30% --layout=reverse)
          if set --query profile
            set -gx AWS_PROFILE $profile
            echo "Switched to AWS profile: $profile"
          end
        '';
      };
      ecr-login = {
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
    };

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

  # GPG configuration
  programs.gpg = {
    enable = true;
    settings = {
      # Use a long keyid format
      keyid-format = "long";
      # Show fingerprints
      with-fingerprint = true;
      # Disable greeting message
      no-greeting = true;
      # Use the GPG agent
      use-agent = true;
    };
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  programs.home-manager.enable = true;

  # Enable man page support
  programs.man.enable = true;

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentry.package = pkgs.pinentry-curses;
    defaultCacheTtl = 28800; # 8 hours
    maxCacheTtl = 86400; # 24 hours
  };
}
