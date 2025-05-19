let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/c16a6c8efedb65e10d565633e3f45f73bbbdf8ab.tar.gz") {
    config = {
      allowUnfree = true;
    };
    overlays = [];
  };
in
  pkgs.mkShellNoCC {
    buildInputs = [
      pkgs.gh
      pkgs.shellcheck
    ];
  }
