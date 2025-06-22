{ config, pkgs, inputs, ... }:

{
  imports = [
    ../common-flake.nix
    ../modules/machine-config-flake.nix
  ];

  # Custom configuration using our module
  myConfig = {
    configPath = "${config.home.homeDirectory}/.config/home-manager/hosts/macbook-air-flake.nix";
    gpgSigningKey = null; # Set your personal GPG key here if needed
  };

  # You can add MacBook Air specific configurations here
  home.packages = with pkgs; [
    # Add any MacBook Air specific tools here
  ];
}
