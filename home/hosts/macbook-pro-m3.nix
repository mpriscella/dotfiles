{ config, pkgs, ... }:

{
  imports = [
    ../modules/shell.nix
    ../modules/editor.nix
    ../programs/git.nix
    ../programs/zsh.nix
  ];

  home.username = "michaelpriscella";  # Use your actual macOS username
  home.homeDirectory = "/Users/michaelpriscella";  # macOS path, not Linux
  home.stateVersion = "24.05"; # always pin this
}
