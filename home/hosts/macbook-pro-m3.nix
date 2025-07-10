{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  gpgConfig = {
    gpgSigningKey = "799887D03FE96FD0";
  };

  imports = [
    ../programs/gpg.nix
    ../programs/git.nix
    ../programs/tmux.nix
    ../programs/yt-dlp.nix
    ../programs/fish.nix
    ../programs/aws.nix
    ../programs/direnv.nix
    ../programs/atuin.nix
  ];

  home.file = {
    ".ackrc".text = ''
      --pager=less -R
      --ignore-case
    '';

    # ".config/atuin".source = ../atuin;
    ".config/ghostty".source = ../../.config/ghostty;
    ".config/k9s".source = ../../.config/k9s;
    ".config/nvim".source = ../../.config/nvim;
  };

  programs.man.enable = true;

  programs.fish.functions.dns-cache-purge = {
    description = "Purge DNS Cache";
    body = ''
      sudo dscacheutil -flushcache
      sudo killall -HUP mDNSResponder
    '';
  };

  home.username = "michaelpriscella";
  home.homeDirectory = "/Users/michaelpriscella";
  home.stateVersion = "24.05";
}

# { config, pkgs, inputs, ... }:

# {
#   imports = [
#     ../common-flake.nix
#     ../modules/machine-config-flake.nix
#   ];

#   # Custom configuration using our module
#   myConfig = {
#     configPath = "${config.home.homeDirectory}/.config/home-manager/hosts/work-macbook-pro-flake.nix";
#   };

#   gpgConfig = {
#     gpgSigningKey = "799887D03FE96FD0";
#   };

#   # You can add work-specific packages or configurations here
#   home.packages = with pkgs; [
#     # Add any work-specific tools here
#   ];

#   programs.fish.functions.dns-cache-purge = {
#     description = "Purge DNS Cache";
#     body = ''
#       sudo dscacheutil -flushcache
#       sudo killall -HUP mDNSResponder
#     '';
#   };
# }
