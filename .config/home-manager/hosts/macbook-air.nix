{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ../modules/machine-config.nix
  ];

  home.username = "mpriscella";
  home.homeDirectory = "/Users/mpriscella";
  home.stateVersion = "25.05";

  # Custom configuration using our module
  myConfig = {
    configPath = "${config.home.homeDirectory}/.config/home-manager/hosts/macbook-air.nix";
    gpgSigningKey = "PERSONAL_GPG_KEY_ID_HERE"; # Personal MacBook Air GPG key
  };
}
