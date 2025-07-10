{ config, pkgs, lib, inputs, ... }:

{
  config = {
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/direnv.nix
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
