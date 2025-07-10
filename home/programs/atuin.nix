{ config, pkgs, lib, inputs, ... }:

{
  config = {
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/atuin.nix
    programs.atuin = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
