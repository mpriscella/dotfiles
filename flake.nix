{
  description = "Personal dotfiles with Home Manager and nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin = {
    #   url = "github:nix-darwin/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # }

    # Optionally, you can pin to specific commits for reproducibility
    # nixpkgs.url = "github:NixOS/nixpkgs/c16a6c8efedb65e10d565633e3f45f73bbbdf8ab";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # Define supported systems
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # Helper to generate configurations for each system
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Helper function to create home-manager configuration
      mkHomeConfiguration = { system, username, homeDirectory, modules ? [], extraSpecialArgs ? {} }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};

          modules = [
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
              home.stateVersion = "25.05";
            }
          ] ++ modules;

          extraSpecialArgs = {
            inherit inputs;
          } // extraSpecialArgs;
        };
    in
    {
      # Home Manager configurations
      homeConfigurations = {
        # Default configuration for Linux (devcontainers, etc.)
        "default" = mkHomeConfiguration {
          system = "x86_64-linux";
          username = "vscode";  # Common devcontainer username
          homeDirectory = "/home/vscode";
          modules = [
            ./.config/home-manager/hosts/default-flake.nix
          ];
        };

        # Work MacBook Pro configuration
        "work-macbook-pro" = mkHomeConfiguration {
          system = "aarch64-darwin";  # Apple Silicon
          username = "michaelpriscella";
          homeDirectory = "/Users/michaelpriscella";
          modules = [
            ./.config/home-manager/hosts/work-macbook-pro-flake.nix
            ./home/programs/git.nix
          ];
        };

        # Generic MacBook Air configuration
        "macbook-air" = mkHomeConfiguration {
          system = "aarch64-darwin";  # Adjust if you have Intel MacBook Air
          username = "user";  # Change this to your actual username
          homeDirectory = "/Users/user";  # Change this to your actual home directory
          modules = [
            ./.config/home-manager/hosts/macbook-air-flake.nix
          ];
        };

        # Alternative Linux configuration for different username
        "linux-user" = mkHomeConfiguration {
          system = "x86_64-linux";
          username = "user";  # Change this to your preferred username
          homeDirectory = "/home/user";
          modules = [
            ./.config/home-manager/hosts/default-flake.nix
          ];
        };
      };

      # Development shells for each system
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            home-manager.packages.${system}.default
            git
            nil  # Nix language server
          ];

          shellHook = ''
            echo "🏠 Home Manager Flake Development Shell"
            echo "Available commands:"
            echo "  home-manager switch --flake .#<configuration>"
            echo "  home-manager build --flake .#<configuration>"
            echo ""
            echo "Available configurations:"
            echo "  default, work-macbook-pro, macbook-air, linux"
            echo ""
            echo "Example: home-manager switch --flake .#work-macbook-pro"
          '';
        };
      });

      # Packages for each system (useful for CI/CD)
      packages = forAllSystems (system:
        let
          # Only include packages that match the target system
          linuxConfigs = nixpkgs.lib.optionalAttrs (nixpkgs.lib.hasInfix "linux" system) {
            default = self.homeConfigurations.default.activationPackage;
            linux-user = self.homeConfigurations.linux-user.activationPackage;
          };
          darwinConfigs = nixpkgs.lib.optionalAttrs (nixpkgs.lib.hasInfix "darwin" system) {
            work-macbook-pro = self.homeConfigurations.work-macbook-pro.activationPackage;
            macbook-air = self.homeConfigurations.macbook-air.activationPackage;
          };
        in
        linuxConfigs // darwinConfigs
      );

      # Formatter for `nix fmt`
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      # Checks for `nix flake check`
      checks = forAllSystems (system:
        let
          # Only include checks that match the target system
          linuxChecks = nixpkgs.lib.optionalAttrs (nixpkgs.lib.hasInfix "linux" system) {
            default = self.packages.${system}.default or null;
            linux-user = self.packages.${system}.linux-user or null;
          };
          darwinChecks = nixpkgs.lib.optionalAttrs (nixpkgs.lib.hasInfix "darwin" system) {
            work-macbook-pro = self.packages.${system}.work-macbook-pro or null;
            macbook-air = self.packages.${system}.macbook-air or null;
          };
        in
        nixpkgs.lib.filterAttrs (_: v: v != null) (linuxChecks // darwinChecks)
      );
    };
}
