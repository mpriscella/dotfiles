{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.fish = {
    enable = true;

    shellAliases = {
      cat = "bat";
      lg = "lazygit";
    };
  };
}
