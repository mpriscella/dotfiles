{ config, pkgs, lib, inputs, ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      container = {
        disabled = true;
      };
      directory = {
        truncate_to_repo = false;
      };
      format = "$all$directory$character";
      git_status = {
        format = ''([\[$ahead_behind\]]($style) )'';
      };
      hostname = {
        disabled = true;
      };
      terraform = {
        disabled = true;
      };
      username = {
        disabled = true;
      };
    };
  };
}
