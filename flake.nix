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
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }@inputs:
    let
      supportedSystems = [ "aarch64-linux" "aarch64-darwin" ];

      # Helper function to get packages for a specific system
      mkPackagesFor = system:
        let pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        in with pkgs; [
          ack
          act
          bat
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
        ];
    in
    {
      homeConfigurations = {
        "macbook-pro-m3" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgsFor "aarch64-darwin";

          modules = [
            (self.outPath + "/home/hosts/macbook-pro-m3.nix")
            {
              home.packages = mkPackagesFor "aarch64-darwin";
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
            echo "  home-manager switch --flake .#work-macbook-pro"
            echo "  home-manager build --flake .#work-macbook-pro"
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
