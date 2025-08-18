{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.gh = {
    enable = true;
    extensions = [pkgs.gh-dash];
  };
}
