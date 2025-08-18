{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.tmux = {
    enable = true;
    prefix = "C-a";
  };
}
