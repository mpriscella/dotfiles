{ config, pkgs, lib, inputs, ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      lg = "lazygit";
    };
  };
}
