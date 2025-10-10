{
  description = "Personal dotfiles with Home Manager and nix-darwin";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
  } @ inputs: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    mkDarwinUser = {username}: {
      environment.shells = ["/run/current-system/sw/bin/fish"];
      users.users.${username} = {
        name = username;
        home = "/Users/${username}";
        shell = "/run/current-system/sw/bin/fish";
      };
    };

    mkHomeConfiguration = {
      system ? "aarch64-darwin",
      username,
      gpgSigningKey ? null,
      isDarwinModule ? false,
      homeDirectory ? null,
      modules ? [],
      extraSpecialArgs ? {},
    }: let
      calculatedHomeDirectory =
        if homeDirectory != null
        then homeDirectory
        else if nixpkgs.lib.hasInfix "darwin" system
        then "/Users/${username}"
        else "/home/${username}";

      baseModules =
        [
          # Only set system metadata when not used as nix-darwin module
          (nixpkgs.lib.optionalAttrs (!isDarwinModule) {
            home.username = username;
            home.homeDirectory = calculatedHomeDirectory;
            home.stateVersion = "25.05";
          })
          ./home-manager/home.nix
        ]
        ++ modules;

      baseExtraSpecialArgs =
        {
          inherit inputs;
          inherit gpgSigningKey;
          inherit isDarwinModule;
          inherit system;
        }
        // extraSpecialArgs;
    in
      if isDarwinModule
      then
        # When used as nix-darwin module, return module configuration directly
        {
          imports = baseModules;
          _module.args = baseExtraSpecialArgs;
        }
      else
        # When used standalone, wrap in homeManagerConfiguration
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = baseModules;
          extraSpecialArgs = baseExtraSpecialArgs;
        };

    mkDarwinConfiguration = {
      system ? "aarch64-darwin",
      hostname,
      username,
      gpgSigningKey,
    }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./nix-darwin/base.nix
          (mkDarwinUser {
            inherit username;
          })
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = nixpkgs.lib.mkMerge [
              (mkHomeConfiguration {
                inherit system username gpgSigningKey;
                isDarwinModule = true;
              })
              {
                home.stateVersion = "25.05";
              }
            ];
          }
        ];
      };
  in {
    darwinConfigurations = {
      "macbook-pro-m3" = mkDarwinConfiguration {
        hostname = "macbook-pro-m3";
        username = "michaelpriscella";
        gpgSigningKey = "799887D03FE96FD0";
      };

      "macbook-air-m4" = mkDarwinConfiguration {
        hostname = "macbook-air-m4";
        username = "mpriscella";
        gpgSigningKey = "27301C740482A8B1";
      };
    };

    homeConfigurations = {
      "linux-arm" = mkHomeConfiguration {
        system = "aarch64-linux";
        username = "mpriscella";
      };
      "linux" = mkHomeConfiguration {
        system = "x86_64-linux";
        username = "mpriscella";
      };
    };

    templates = {
      default = {
        path = ./templates/default;
        description = "A minimal Nix flake template
        for reproducible multi-system builds and dev environments.";
      };
    };

    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs =
          [
            home-manager.packages.${system}.default
            nixpkgs.legacyPackages.${system}.cargo
            nixpkgs.legacyPackages.${system}.python3
            nixpkgs.legacyPackages.${system}.nix-diff
            nixpkgs.legacyPackages.${system}.nh
            (nixpkgs.legacyPackages.${system}.writeShellScriptBin "nvim-dev" ''
              XDG_CONFIG_HOME="config/" nvim "$@"
            '')
          ]
          ++ nixpkgs.lib.optionals (nixpkgs.lib.hasInfix "darwin" system) [
            nix-darwin.packages.${system}.darwin-rebuild
          ];

        shellHook = ''
          cat <<EOF
              ____        __  _____ __
             / __ \____  / /_/ __(_) /__  _____
            / / / / __ \/ __/ /_/ / / _ \/ ___/
           / /_/ / /_/ / /_/ __/ / /  __(__  )
          /_____/\____/\__/_/ /_/_/\___/____/
          EOF

          echo ""
          echo "Nix Darwin commands:"
          echo "  sudo darwin-rebuild build --flake .#<hostname>   # Build system config"
          echo "  sudo darwin-rebuild switch --flake .#<hostname>  # Apply system config"
          echo "  sudo darwin-rebuild switch --rollback            # Rollback to previous config"
          echo "  nvim-dev [files]                                 # Neovim with isolated config"
          echo ""
          echo "Available Nix Darwin configurations:"
          echo "  macbook-pro-m3, macbook-air-m4"
          echo ""
          echo ""
          echo "Home Manager commands:"
          echo "  home-manager build --flake .#<hostname>          # Build home-manager config"
          echo "  home-manager switch --flake .#<hostname>         # Apply home-manager config"
          echo "  home-manager switch --rollback                   # Rollback to previous config"
          echo ""
          echo "Available Home Manager configurations:"
          echo "  linux, linux-arm"
          echo ""
          echo ""
          echo "Nix commands:"
          echo "  nix flake check                                  # Validate and test flake"
          echo "  nix flake update                                 # Update dependencies"
          echo "  nix fmt flake.nix home-manager nix-darwin        # Format code"
          echo "  sudo determinate-nixd upgrade                    # Upgrade Nix"
          echo ""
          echo ""
          echo "Nix Helper (nh) commands:"
          echo "  nh clean all                                     # Clean Nix store"
          echo "  nh search <query> [--limit n]                    # Search packages"
        '';
      };
    });

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    checks = forAllSystems (
      system: let
        macosChecks = nixpkgs.lib.optionalAttrs (nixpkgs.lib.hasInfix "darwin" system) {
          macbook-pro-m3 = self.darwinConfigurations."macbook-pro-m3".system;
          macbook-air-m4 = self.darwinConfigurations."macbook-air-m4".system;
        };
        linuxChecks = nixpkgs.lib.optionalAttrs (nixpkgs.lib.hasInfix "linux" system) {
          linux =
            (mkHomeConfiguration {
              system = system;
              username = "mpriscella";
            }).activationPackage;
        };
      in
        macosChecks // linuxChecks
    );
  };
}
