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
      # Define the systems we want to support
      supportedSystems = [ "aarch64-linux" "aarch64-darwin" ];

      # Helper function to get packages for a specific system
      mkPackagesFor = system:
        let pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        in with pkgs; [
          ack act bat dive fd fzf git graphviz jq kind kubectl
          kubernetes-helm lazydocker neovim nodejs_24 ripgrep yq
        ];

      mkPkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkDevPackagesFor = system:
        let pkgs = mkPkgsFor system;
        in with pkgs; [
          home-manager.packages.${system}.default
          nixpkgs-fmt nil nix-tree
        ];
    in
    {
      homeConfigurations = {
        "dotfiles-utm" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgsFor "aarch64-darwin";

          modules = [
            {
              home.username = "dotfiles";
              home.homeDirectory = "/Users/dotfiles";
              home.stateVersion = "25.05";

              # Use the system-specific packages
              home.packages = mkPackagesFor "aarch64-darwin";
            }
            (self.outPath + "/.config/home-manager/hosts/work-macbook-pro-flake.nix")
            (self.outPath + "/home/programs/gpg.nix")
            (self.outPath + "/home/programs/git.nix")
            (self.outPath + "/home/programs/tmux.nix")
            (self.outPath + "/home/programs/yt-dlp.nix")
            (self.outPath + "/home/programs/fish.nix")
            (self.outPath + "/home/programs/aws.nix")
            (self.outPath + "/home/programs/direnv.nix")
            (self.outPath + "/home/programs/atuin.nix")
          ];
        };

        "macbook-pro-m3" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgsFor "aarch64-darwin";

          modules = [
            (self.outPath + "/home/hosts/macbook-pro-m3.nix")
            {
              home.packages = mkPackagesFor "aarch64-darwin";
            }
          ];
        };

        "work-macbook-pro" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgsFor "aarch64-darwin";

          modules = [
            {
              home.username = "michaelpriscella";
              home.homeDirectory = "/Users/michaelpriscella";
              home.stateVersion = "25.05";

              # Use the system-specific packages
              home.packages = mkPackagesFor "aarch64-darwin";
            }
            (self.outPath + "/.config/home-manager/hosts/work-macbook-pro-flake.nix")
            (self.outPath + "/home/programs/gpg.nix")
            (self.outPath + "/home/programs/git.nix")
            (self.outPath + "/home/programs/tmux.nix")
            (self.outPath + "/home/programs/yt-dlp.nix")
            (self.outPath + "/home/programs/fish.nix")
            (self.outPath + "/home/programs/aws.nix")
            (self.outPath + "/home/programs/direnv.nix")
            (self.outPath + "/home/programs/atuin.nix")
          ];
        };

        # Easy to add more systems
        # "personal-linux" = home-manager.lib.homeManagerConfiguration {
        #   pkgs = mkPkgsFor "x86_64-linux";

        #   modules = [
        #     {
        #       home.username = "mpriscella";
        #       home.homeDirectory = "/home/mpriscella";
        #       home.stateVersion = "25.05";
        #       home.packages = mkPackagesFor "x86_64-linux";
        #     }
        #     # ... other modules
        #   ];
        # };
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
