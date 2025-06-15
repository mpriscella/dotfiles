{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ../modules/machine-config.nix
  ];

  home.username = "michaelpriscella";
  home.homeDirectory = "/Users/michaelpriscella";
  home.stateVersion = "25.05";

  # Custom configuration using our module
  myConfig = {
    configPath = "${config.home.homeDirectory}/.config/home-manager/hosts/work-macbook-pro.nix";
  };
}
