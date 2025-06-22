{ config, pkgs, lib, inputs, ... }:

let
  # Get GPG signing key from host configuration, with fallback
  gpgSigningKey = config.myConfig.gpgSigningKey or null;
in

{
  # Allow unfree packages (like some proprietary tools)
  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.ack
    pkgs.act
    pkgs.awscli2
    pkgs.dive
    pkgs.fd
    pkgs.fzf
    pkgs.gh
    pkgs.git
    pkgs.gnupg
    pkgs.jq
    pkgs.kind
    pkgs.k9s
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.lazydocker
    pkgs.lazygit
    pkgs.neovim
    pkgs.pinentry-curses  # For GPG password prompts in terminal
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
      # AWS profile switcher
      aws-ps = {
        description = "Switch AWS profiles";
        body = ''
          set -l profile $argv[1]
          if test -z "$profile"
            echo "Available profiles:"
            aws configure list-profiles
            return
          end
          set -gx AWS_PROFILE $profile
          echo "Switched to AWS profile: $profile"
        '';
      };
    };

    shellAliases = {
      # Modern replacements
      cat = "bat --style=plain";
      find = "fd";
      grep = "rg";

      # Nix flake aliases
      nfc = "nix flake check";
      nfu = "nix flake update";
      nfs = "nix flake show";
    };

    plugins = [
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Mike Priscella";
    userEmail = "mpriscella@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      core.editor = "nvim";

      # GPG signing configuration (conditional)
      user.signingkey = lib.mkIf (gpgSigningKey != null) gpgSigningKey;
      commit.gpgsign = lib.mkIf (gpgSigningKey != null) true;
      tag.gpgsign = lib.mkIf (gpgSigningKey != null) true;
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".direnv/"
      "result"
      "result-*"
    ];

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      di = "diff";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
      graph = "log --oneline --graph --decorate --all";
      # Show files ignored by git
      ign = "ls-files -o -i --exclude-standard";
    };
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
    defaultCacheTtl = 28800;  # 8 hours
    maxCacheTtl = 86400;      # 24 hours
  };
}
