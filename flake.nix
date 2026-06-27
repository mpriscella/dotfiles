{
  description = "Personal dotfiles with Home Manager and nix-darwin";

  inputs = {
    nixpkgs = {
      url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    sops-nix,
  } @ inputs: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    mkDarwinUser = {username}: {
      environment.shells = ["/run/current-system/sw/bin/fish"];
      # knownUsers (with a matching uid) is required for nix-darwin to actually
      # enforce the shell via dscl — without it the shell setting is decorative.
      users.knownUsers = [username];
      users.users.${username} = {
        name = username;
        home = "/Users/${username}";
        shell = "/run/current-system/sw/bin/fish";
        uid = 501;
      };
      system.primaryUser = username;
    };

    # Shared user identity configuration
    userConfig = {
      name = "Mike Priscella";
      email = "mpriscella@gmail.com";
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
          sops-nix.homeManagerModules.sops
          ./home-manager/home.nix
        ]
        ++ modules;

      baseExtraSpecialArgs =
        {
          inherit inputs;
          inherit gpgSigningKey;
          inherit isDarwinModule;
          inherit system;
          inherit userConfig;
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
      "macbook-pro-m5" = mkDarwinConfiguration {
        username = "mpriscella";
        gpgSigningKey = "DD1E20A6B283BC4E";
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
            (nixpkgs.legacyPackages.${system}.writeShellScriptBin "nvim-dev" ''
              # Isolate XDG_CONFIG_HOME in a temp dir holding only a symlink to
              # the repo's nvim config. Pointing it at config/ directly lets
              # child processes (fish, via :! and friends) scribble their own
              # config files into the repo, and a relative XDG_CONFIG_HOME
              # breaks if the working directory changes inside nvim.
              tmp=$(mktemp -d)
              trap 'rm -rf "$tmp"' EXIT
              ln -s "$PWD/config/nvim" "$tmp/nvim"
              XDG_CONFIG_HOME="$tmp" nvim "$@"
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
          echo "  macbook-pro-m5"
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
          echo ""
          echo ""
          echo "Nix Helper (nh) commands:"
          echo "  nh darwin switch -H <hostname>                   # Apply system config (shows package diff)"
          echo "  nh home switch -c <configuration>                # Apply home-manager config (shows package diff)"
          echo "  nh clean all                                     # Clean Nix store"
          echo "  nh search <query> [--limit n]                    # Search packages"
        '';
      };
    });

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    checks = forAllSystems (
      system: let
        macosChecks = nixpkgs.lib.optionalAttrs (nixpkgs.lib.hasInfix "darwin" system) (
          nixpkgs.lib.mapAttrs (_: cfg: cfg.system) self.darwinConfigurations
        );
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
