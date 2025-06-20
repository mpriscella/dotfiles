{ config, pkgs, inputs, ... }:

{
  imports = [
    ../common-flake.nix
    ../modules/machine-config-flake.nix
  ];

  # Custom configuration using our module
  myConfig = {
    configPath = "${config.home.homeDirectory}/.config/home-manager/hosts/default-flake.nix";
    gpgSigningKey = null; # No default GPG key
  };
}
