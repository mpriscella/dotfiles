{ config, pkgs, ... }:

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

    ".config/atuin/config.toml".source = ../atuin/config.toml;
    ".config/ghostty/config".source = ../ghostty/config;
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
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
