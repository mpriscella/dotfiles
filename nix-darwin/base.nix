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

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };

    casks = ["devtoys"];
  };

  environment.systemPackages = [
    pkgs.bruno
    pkgs.dbeaver-bin
    pkgs.shottr
    pkgs.vlc-bin
  ];
}
