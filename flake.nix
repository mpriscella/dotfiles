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
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    mkPackagesFor = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    # Helper function to create a nix-darwin user configuration.
    mkDarwinUser = {
      username,
      system,
    }: {
      environment.shells = ["/run/current-system/sw/bin/fish"];
      users.users.${username} = {
        name = username;
        home = "/Users/${username}";
        shell = "/run/current-system/sw/bin/fish";
      };
    };

    # Helper function to create home-manager configurations.
    mkHomeConfiguration = {
      system,
      username,
      homeDirectory ? null,
      modules ? [],
      extraSpecialArgs ? {},
      gpgSigningKey ? null,
      isDarwinModule ? false,
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
  in {
    darwinConfigurations = {
      "macbook-pro-m3" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./nix-darwin/determinate-nix.nix
          (mkDarwinUser {
            username = "michaelpriscella";
            system = "aarch64-darwin";
          })
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.michaelpriscella = nixpkgs.lib.mkMerge [
              (mkHomeConfiguration {
                system = "aarch64-darwin";
                username = "michaelpriscella";
                gpgSigningKey = "799887D03FE96FD0";
                isDarwinModule = true;
              })
              {
                home.stateVersion = "25.05";
              }
            ];
          }
        ];
      };

      "macbook-air-m4" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./nix-darwin/official-nix.nix
          (mkDarwinUser {
            username = "mpriscella";
            system = "aarch64-darwin";
          })
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mpriscella = nixpkgs.lib.mkMerge [
              (mkHomeConfiguration {
                system = "aarch64-darwin";
                username = "mpriscella";
                gpgSigningKey = "27301C740482A8B1";
                isDarwinModule = true;
              })
              {
                home.stateVersion = "25.05";
              }
            ];
          }
        ];
      };
    };

    homeConfigurations = {
      "macbook-pro-m3" = mkHomeConfiguration {
        system = "aarch64-darwin";
        username = "michaelpriscella";
        gpgSigningKey = "799887D03FE96FD0";
      };

      "nixos-orbstack" = mkHomeConfiguration {
        system = "aarch64-linux";
        username = "mpriscella";
      };
    };

    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = [
          home-manager.packages.${system}.default
          nix-darwin.packages.${system}.darwin-rebuild
          nixpkgs.legacyPackages.${system}.python3
          nixpkgs.legacyPackages.${system}.nix-diff
          nixpkgs.legacyPackages.${system}.nh
          (nixpkgs.legacyPackages.${system}.writeShellScriptBin "nvim-dev" ''
            XDG_CONFIG_HOME="config/" nvim "$@"
          '')
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
          echo "  macbook-pro-m3, nixos-orbstack"
          echo ""
          echo ""
          echo "Nix commands:"
          echo "  nix flake check                                  # Validate and test flake"
          echo "  nix flake update                                 # Update dependencies"
          echo "  nix fmt flake.nix home-manager nix-darwin        # Format code"
          echo "  nix upgrade-nix                                  # Upgrade Nix"
        '';
      };
    });

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    checks = forAllSystems (
      system: let
        macosChecks = nixpkgs.lib.optionalAttrs (nixpkgs.lib.hasInfix "darwin" system) {
          home-manager-macbook-pro-m3 = self.homeConfigurations."macbook-pro-m3".activationPackage;
          nix-darwin-macbook-pro-m3 = self.darwinConfigurations."macbook-pro-m3".system;
          nix-darwin-macbook-air-m4 = self.darwinConfigurations."macbook-air-m4".system;
        };
        linuxChecks = nixpkgs.lib.optionalAttrs (nixpkgs.lib.hasInfix "linux" system) {
          nixos-orbstack = self.homeConfigurations."nixos-orbstack".activationPackage;
        };
      in
        macosChecks // linuxChecks
    );
  };
}
