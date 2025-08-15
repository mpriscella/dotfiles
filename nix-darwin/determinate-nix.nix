{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  # Nix daemon configuration
  nix = {
    enable = false;
  };
}
