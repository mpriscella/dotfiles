{
  config,
  pkgs,
  ...
}: {
  nix = {
    enable = false;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  programs.fish.enable = true;

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    stateVersion = 6;
  };

  environment.systemPackages = [
    pkgs._1password-gui
    pkgs.betterdisplay
    pkgs.bruno
    pkgs.dbeaver-bin
    pkgs.discord
    pkgs.firefox
    pkgs.obsidian
    pkgs.shottr
    pkgs.utm
    pkgs.vlc-bin
    pkgs.vscode
  ];
}
