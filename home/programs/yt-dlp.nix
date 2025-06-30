{ config, pkgs, lib, inputs, ... }:

{
  config = {
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/yt-dlp.nix
    programs.yt-dlp = {
      enable = true;
    };
  };
}
