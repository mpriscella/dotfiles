{ config, pkgs, ... }:

{
  # Enable Fish shell system-wide
  programs.fish.enable = true;

  # Nix daemon configuration
  nix = {
    enable = false;
  };

  system.stateVersion = 6;
}
