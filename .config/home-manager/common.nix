{ config, pkgs, lib, ... }:

let
  # Get GPG signing key from host configuration, with fallback
  gpgSigningKey = config.myConfig.gpgSigningKey or null;
in

{
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
    KUBE_EDITOR = "nvim";
  };

  # Enable and configure Fish shell
  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];

    functions = {
      aws-ps = ''
        set profile $(aws configure list-profiles | fzf --height=30% --layout=reverse)
        if set --query profile
            set -gx AWS_PROFILE $profile
            echo "AWS profile $AWS_PROFILE now active."
        end
      '';
    };

    # Fish shell configuration
    shellInit = ''
      # Commands to run when fish starts (non-interactive)
      set PATH $PATH /opt/homebrew/bin
      set PATH $HOME/.orbstack/bin $PATH
    '';

    interactiveShellInit = ''
      # Commands to run in interactive sessions
      # Initialize atuin if available
      if command -q atuin
        atuin init fish | source
      end
    '';

    # Fish shell aliases
    shellAliases = {
      lg = "lazygit";

      # Quick reload aliases
      rl = "exec fish";
      src = "source ~/.config/fish/config.fish";

      # Home Manager aliases
      hm = "home-manager";
      hms = "home-manager switch";
      hmb = "home-manager build --no-out-link";

      # GPG aliases for easier key management
      gpg-list = "gpg --list-secret-keys --keyid-format=long";
      gpg-export = "gpg --armor --export";
      gpg-restart = "gpg-connect-agent reloadagent /bye";
    };
  };

  # Configure direnv with nix-direnv for automatic Nix environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Mike Priscella";
    userEmail = "mpriscella@gmail.com";

    extraConfig = {
      core.editor = "nvim";
      color.ui = "auto";
      init.defaultBranch = "main";
      pull.rebase = false;
      push.default = "simple";

      # GPG signing configuration
      commit.gpgsign = true;
      tag.gpgsign = true;
    };

    aliases = {
      chb = "checkout -b";
      empty = "commit --allow-empty -n -m 'Empty-Commit'";
    };

    ignores = [
      # OS generated files
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "ehthumbs.db"
      "Thumbs.db"

      # IDE files
      ".vscode/"
      ".idea/"
      "*.swp"
      "*.swo"
      "*~"

      # Build artifacts
      "node_modules/"
      "target/"
      "dist/"
      "build/"

      # Environment files
      ".env"
      ".env.local"
    ];
  } // lib.optionalAttrs (gpgSigningKey != null) {
    signing = {
      key = gpgSigningKey;
      signByDefault = true;
    };
  };

  # Configure GPG for commit signing
  programs.gpg = {
    enable = true;

    # Configure GPG settings
    settings = {
      # Use agent for key management
      use-agent = true;
      # Default key preferences
      personal-digest-preferences = "SHA512";
      cert-digest-algo = "SHA512";
      default-preference-list = "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";
    };
  };

  # Configure GPG agent for automatic key management
  services.gpg-agent = {
    enable = true;

    # Cache settings for convenience
    defaultCacheTtl = 43200; # 12 hours (longer default)
    maxCacheTtl = 86400;     # 24 hours

    # Enable SSH support (optional, useful for SSH key management)
    enableSshSupport = false;

    # Pin entry program for password prompts
    pinentry = {
      package = pkgs.pinentry-curses; # Use curses for terminal, or pkgs.pinentry-gtk2 for GUI
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
