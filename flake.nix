{
  description = "Personal dotfiles with Home Manager and nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, nix-darwin, ... }@inputs:
    let
      supportedSystems = [ "aarch64-linux" "aarch64-darwin" ];

      # Helper function to get packages for a specific system
      mkPackagesFor = system:
        let pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        in with pkgs; [
          ack
          act
          atuin
          bat
          cargo
          dive
          fd
          fzf
          graphviz
          jq
          kind
          kubectl
          kubernetes-helm
          lazydocker
          neovim
          nodejs_24
          ripgrep
          yq
        ];

      mkPkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkDevPackagesFor = system:
        let pkgs = mkPkgsFor system;
        in with pkgs; [
          home-manager.packages.${system}.default
          nixpkgs-fmt
          nil
          nix-tree
          nix-darwin.packages.${system}.darwin-rebuild
        ];
    in
    {
      darwinConfigurations = {
        "ideal" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs self; };
          modules = [
            ./home/modules/global.nix
            # Global
              # Global packages (linux + Mac)
              # Default configurations
                # Dotfiles

            ./home/modules/darwin.nix
            # Darwin
              # Darwin specific packages
              # Darwin configurations
                # Dock

            # Home Manager
            home-manager.darwinModules.home-manager
            {
              imports = [
                ./home/modules/home-base.nix
              ];
              # Somehow I need to import all of those programs as home-manager modules here.
            }

            # Host
              # Host-specific packages
              # Host-specific configurations
          ];
        };

        "macbook-pro-m3" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs self; };
          modules = [
            ./home/modules/darwin-base.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # users.users.michaelpriscella.home = "/Users/michaelpriscella";
              home-manager.users.michaelpriscella = import ./home/hosts/macbook-pro-m3.nix;
              environment.systemPackages = mkPackagesFor "aarch64-darwin";
            }
          ];
        };
      };

      # Pass through the system-specific outputs from flake-utils
      devShells = nixpkgs.lib.genAttrs supportedSystems (system: {
        default = (mkPkgsFor system).mkShell {
          name = "dotfiles-dev";
          buildInputs = (mkPackagesFor system) ++ (mkDevPackagesFor system);

          shellHook = ''
            echo "🏠 Dotfiles Development Shell (${system})"
            echo "📦 Available packages: ${toString (builtins.length (mkPackagesFor system))}"
            echo ""
            echo "Commands:"
            echo "  darwin-rebuild switch --flake .#macbook-pro-m3"
            echo "  nix flake check"
            echo "  nixpkgs-fmt ."
          '';
        };
      });

      # Pass through formatters
      formatter = nixpkgs.lib.genAttrs supportedSystems (system:
        (mkPkgsFor system).nixpkgs-fmt
      );

      # Optional: Expose the packages for other uses
      packages = nixpkgs.lib.genAttrs supportedSystems (system: {
        commonPackages = (mkPkgsFor system).buildEnv {
          name = "common-packages";
          paths = mkPackagesFor system;
        };
      });
    };
}
