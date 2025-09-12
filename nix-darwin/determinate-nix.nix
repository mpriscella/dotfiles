{
  config,
  pkgs,
  ...
}: {
  # Nix daemon configuration
  nix = {
    enable = false;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
