{
  config,
  pkgs,
  ...
}: {
  programs.fish.enable = true;

  system.stateVersion = 6;

  environment.systemPackages = [
    pkgs._1password-gui
    pkgs.bruno
    pkgs.dbeaver-bin
    pkgs.discord
    pkgs.firefox
    pkgs.obsidian
    pkgs.shottr
    pkgs.vscode
  ];
}
