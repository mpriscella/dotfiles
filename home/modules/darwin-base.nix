# home/modules/darwin-base.nix
{ config, pkgs, ... }:

{
  # Allow unfree packages (common for macOS)
  nixpkgs.config.allowUnfree = true;

  # Common Mac packages
  home.packages = with pkgs; [
    # macOS-specific tools
    # mas  # Mac App Store CLI (if you want to manage App Store apps)
    # rectangle  # Window management
    # Add other Mac-specific packages here
  ];

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

    # Add other Mac-specific functions
    # show-hidden = {
    #   description = "Show hidden files in Finder";
    #   body = "defaults write com.apple.finder AppleShowAllFiles YES; killall Finder";
    # };

    # hide-hidden = {
    #   description = "Hide hidden files in Finder";
    #   body = "defaults write com.apple.finder AppleShowAllFiles NO; killall Finder";
    # };
  };

  # Common Mac imports
  imports = [
    ../programs/gpg.nix
    ../programs/git.nix
    ../programs/tmux.nix
    ../programs/yt-dlp.nix
    ../programs/fish.nix
    ../programs/aws.nix
    ../programs/direnv.nix
    ../programs/atuin.nix
    ../programs/k9s.nix
  ];
}
