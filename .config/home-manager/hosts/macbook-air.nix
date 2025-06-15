{ config, pkgs, ... }:

{
  imports = [ ../common.nix ];

  # Machine-specific configuration
  home.username = "michaelpriscella";
  home.homeDirectory = "/Users/michaelpriscella";
  home.stateVersion = "25.05";

  # Machine-specific packages or overrides can go here
  # home.packages = with pkgs; [
  #   # Additional packages for this machine
  # ];
}
