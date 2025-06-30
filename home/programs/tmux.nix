{ config, pkgs, lib, inputs, ... }:

{
  config = {
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/tmux.nix
    programs.tmux = {
      enable = true;
      prefix = "C-a";
    };
  };
}
