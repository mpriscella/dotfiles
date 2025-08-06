{ config, pkgs, lib, inputs, ... }:

{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };
}
