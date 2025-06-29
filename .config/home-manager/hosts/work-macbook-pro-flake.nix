{ config, pkgs, inputs, ... }:

{
  imports = [
    ../common-flake.nix
    ../modules/machine-config-flake.nix
  ];

  # Custom configuration using our module
  myConfig = {
    configPath = "${config.home.homeDirectory}/.config/home-manager/hosts/work-macbook-pro-flake.nix";
    gpgSigningKey = "799887D03FE96FD0"; # Work-specific GPG key
  };

  # You can add work-specific packages or configurations here
  home.packages = with pkgs; [
    # Add any work-specific tools here
  ];
}
