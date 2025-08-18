{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.yt-dlp = {
    enable = true;
  };
}
