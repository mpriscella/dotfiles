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
      };
    };
}
