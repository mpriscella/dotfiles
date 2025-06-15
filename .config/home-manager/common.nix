{ config, pkgs, ... }:

{
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.ack
    pkgs.act
    pkgs.awscli2
    pkgs.fd
    pkgs.fzf
    pkgs.gh
    pkgs.git  # Explicitly install git for programs.git to work
    pkgs.gnupg
    pkgs.kind
    pkgs.k9s
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.lazygit
    pkgs.neovim
    pkgs.ripgrep
    pkgs.tmux
    pkgs.yq
    pkgs.yt-dlp
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # Method 1: Inline content (best for small config files)
#   ".gitignore_global".text = ''
#     # OS generated files
#     .DS_Store
#     .DS_Store?
#     ._*
#     .Spotlight-V100
#     .Trashes
#     ehthumbs.db
#     Thumbs.db

#     # IDE files
#     .vscode/
#     .idea/
#     *.swp
#     *.swo
#     *~

#     # Build artifacts
#     node_modules/
#     target/
#     dist/
#     build/

#     # Environment files
#     .env
#     .env.local
#   '';

    # Method 2: Simple file with basic content
#   ".hushlogin".text = "";  # Suppress login banner

    # Method 3: Executable script
#   ".local/bin/hello".text = ''
#     #!/usr/bin/env bash
#     echo "Hello from Home Manager!"
#   '';
#   ".local/bin/hello".executable = true;

    # Method 2: Source from external files (best for large configs)
#   ".tmux.conf".source = ../../tmux.conf;
#   ".gitconfig".source = ../../gitconfig;

    # Method 3: Conditional files (using Nix expressions)
#   ".vimrc".text = ''
#     set number
#     set relativenumber
#     set tabstop=2
#     set shiftwidth=2
#     set expandtab
#     ${if pkgs.stdenv.isDarwin then "set clipboard=unnamed" else "set clipboard=unnamedplus"}
#   '';
  };

  # Common session variables
  home.sessionVariables = {
    EDITOR = "nvim";
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

#     # Function to reload Fish shell configuration
#     reload = ''
#       echo "Reloading Fish shell configuration..."
#       exec fish
#     '';

#     # Enhanced rebuild function that reloads Fish afterwards
#     hm-switch = ''
#       if test -n "$HM_CONFIG_PATH"
#         echo "Switching Home Manager configuration..."
#         home-manager switch --file "$HM_CONFIG_PATH" $argv
#         and begin
#           echo "Reloading Fish shell..."
#           exec fish
#         end
#       else
#         echo "Error: HM_CONFIG_PATH not set. Please set it to your machine config path."
#         return 1
#       end
#     '';
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
