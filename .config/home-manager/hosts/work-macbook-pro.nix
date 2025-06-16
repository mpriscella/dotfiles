{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ../modules/machine-config.nix
  ];

  home.username = "michaelpriscella";
  home.homeDirectory = "/Users/michaelpriscella";
  home.stateVersion = "25.05";

  myConfig = {
    configPath = "${config.home.homeDirectory}/.config/home-manager/hosts/work-macbook-pro.nix";
    gpgSigningKey = "799887D03FE96FD0";
  };
}
