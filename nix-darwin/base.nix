{ config, pkgs, ... }:

{
  # Enable Fish shell system-wide
  programs.fish.enable = true;

  system.stateVersion = 6;
}
