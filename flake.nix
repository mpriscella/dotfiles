{
  description = "Personal dotfiles with Home Manager and nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager }:
    let
      mkPackagesFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      defaultPackages = pkgs: with pkgs; [
        ack
        act
        atuin
        bat
        delta
        dive
        fd
        fzf
        gh
        graphviz
        jq
        kind
        kubectl
        kubernetes-helm
        lazydocker
        lazygit
        neovim
        nil
        ripgrep
        yq
      ];
    in
    {
      darwinConfigurations = {
        "macbook-pro-m3" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./home/modules/darwin.nix
            {
              users.users.michaelpriscella = {
                name = "michaelpriscella";
                home = "/Users/michaelpriscella";
              };
            }
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.michaelpriscella = {
                home.stateVersion = "24.05";
                imports = [
                  ./home/modules/home-base.nix
                ];

                home.packages = defaultPackages (mkPackagesFor "aarch64-darwin");

                gpgConfig = {
                  gpgSigningKey = "799887D03FE96FD0";
                };
              };
            }
          ];
        };
      };

      devShells.aarch64-darwin.default =
        let
          pkgs = mkPackagesFor "aarch64-darwin";
        in
        pkgs.mkShell {
          buildInputs = (defaultPackages pkgs) ++ [
            nix-darwin.packages.aarch64-darwin.darwin-rebuild
            pkgs.nodejs_24 # To build neovim packages.
          ];

          shellHook = ''
            echo "🏠 Dotfiles Development Shell"
            echo "Available commands:"
            echo "  sudo darwin-rebuild switch --flake .#macbook-pro-m3  # Apply system configuration"
            echo "  nix flake update                                     # Update dependencies"
            echo "  nix fmt flake.nix home/                              # Format Nix files"
            echo "  nix flake check                                      # Validate flake"
          '';
        };

      formatter.aarch64-darwin = (mkPackagesFor "aarch64-darwin").nixpkgs-fmt;
    };
}
