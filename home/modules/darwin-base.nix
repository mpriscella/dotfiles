# home/modules/darwin-base.nix
{ config, pkgs, ... }:

{
  # Allow unfree packages (common for macOS)
  nixpkgs.config.allowUnfree = true;

  # Only darwin/system-level options should remain here.
  system.stateVersion = 6;

  nix.enable = false;

  programs.fish.enable = true;

  users.users.michaelpriscella.shell = pkgs.fish;

  environment.systemPackages = [ pkgs.fish pkgs.atuin ];
}
