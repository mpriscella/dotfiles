{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ../modules/machine-config.nix
  ];

  home.username = "mpriscella";
  home.homeDirectory = "/Users/mpriscella";
  home.stateVersion = "25.05";

  myConfig = {
    configPath = "${config.home.homeDirectory}/.config/home-manager/hosts/macbook-air.nix";
    gpgSigningKey = "27301C740482A8B1";
  };
}
