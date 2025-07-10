{ config, pkgs, ... }:

{
  imports = [
    ../modules/darwin-base.nix
  ];

  gpgConfig = {
    gpgSigningKey = "799887D03FE96FD0";
  };

  home.username = "michaelpriscella";
  home.homeDirectory = "/Users/michaelpriscella";
  home.stateVersion = "24.05";
}
