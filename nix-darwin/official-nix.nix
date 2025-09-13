{
  config,
  pkgs,
  ...
}: {
  # imports = [
  #   ./base.nix
  # ];
  #
  nix = {
    enable = true;

    linux-builder = {
      enable = true;
    };

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
