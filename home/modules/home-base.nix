{ config, pkgs, lib, ... }:

{
  imports = [
    ../programs/gpg.nix
    # ../programs/aws.nix
    ../programs/git.nix
    ../programs/tmux.nix
    ../programs/yt-dlp.nix
    ../programs/fish.nix
    ../programs/direnv.nix
    ../programs/atuin.nix
    ../programs/k9s.nix
  ];

  # Common Mac packages
  # home.packages = lib.mkBefore (with pkgs; [
  #   # mas  # Mac App Store CLI (if you want to manage App Store apps)
  #   # rectangle  # Window management
  #   # Add other Mac-specific packages here
  # ]);

  # Common Mac file configurations
  home.file = {
    ".ackrc".text = ''
      --pager=less -R
      --ignore-case
    '';
    ".config/ghostty".source = ../../.config/ghostty;
    ".config/nvim".source = ../../.config/nvim;
  };

  # Common Mac session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "less";
    LESS = "-R";
  };

  # Common Mac program configurations
  programs.man.enable = true;

  # Common Mac shell functions
  programs.fish.functions = {
    dns-cache-purge = {
      description = "Purge DNS Cache";
      body = ''
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
      '';
    };
    # Add other Mac-specific functions here
  };
}
