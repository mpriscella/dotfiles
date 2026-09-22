{
  description = "Personal dotfiles with Home Manager and nix-darwin";

  inputs = {
    nixpkgs = {
      url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
    };

    nixpkgs-unstable = {
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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Packages not in nixpkgs (laravel-lsp, laravel-cloud-cli), kept in their
    # own flake so other repos can consume them without inheriting everything
    # above. Applied below as an overlay.
    nix-packages = {
      url = "github:mpriscella/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    home-manager,
    sops-nix,
    nix-packages,
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
      # Top-level profile module. home.nix is the full workstation; the
      # codespaces profile swaps in a much smaller one (see
      # home-manager/codespaces.nix). They are alternatives, never combined.
      homeModule ? ./home-manager/home.nix,
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
          homeModule
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
          # Imported explicitly rather than taken from legacyPackages, because
          # overlays can only be applied at import time. allowUnfree is set
          # here too: home.nix requests it through home-manager's
          # `nixpkgs.config` option, which home-manager ignores whenever a
          # `pkgs` is handed to it like this.
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [nix-packages.overlays.default];
          };
          modules = baseModules;
          extraSpecialArgs = baseExtraSpecialArgs;
        };

    mkDarwinConfiguration = {
      system ? "aarch64-darwin",
      username,
      gpgSigningKey ? null,
    }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          # Set here rather than in base.nix because darwinSystem is called
          # without specialArgs, so the modules themselves cannot see `inputs`.
          # home-manager.useGlobalPkgs below means Home Manager inherits it.
          {nixpkgs.overlays = [nix-packages.overlays.default];}
          ./nix-darwin/base.nix
          ./nix-darwin/karabiner.nix
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
                modules = [./home-manager/darwin.nix];
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
      };

      "macbook-pro-m3" = mkDarwinConfiguration {
        username = "mpriscella";
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

      # Codespaces / dev containers: neovim plus a familiar shell, nothing
      # that needs a secret or a signing key. install.sh selects these
      # automatically when $CODESPACES is set. The username must match the
      # container's user — `codespace` in the GitHub-provided images; add
      # another entry here for a devcontainer that runs as `vscode` or `node`.
      "codespaces" = mkHomeConfiguration {
        system = "x86_64-linux";
        username = "codespace";
        homeModule = ./home-manager/codespaces.nix;
      };
      "codespaces-arm" = mkHomeConfiguration {
        system = "aarch64-linux";
        username = "codespace";
        homeModule = ./home-manager/codespaces.nix;
      };
    };

    # Bootstrap a machine that already has Nix:
    #   nix run github:mpriscella/dotfiles#install [-- --build-only <config>]
    # This is install.sh minus its Nix-install step (the script detects Nix is
    # present and skips it). A truly bare machine still needs ./install.sh or
    # the curl | bash bootstrap, since `nix run` can't run before Nix exists.
    # Run from the flake ref there is no local checkout, so the script clones
    # the repo to its default DOTFILES_DIR before applying.
    apps = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      install = {
        type = "app";
        program = nixpkgs.lib.getExe (pkgs.writeShellApplication {
          name = "dotfiles-install";
          runtimeInputs = [pkgs.git pkgs.curl];
          text = builtins.readFile ./install.sh;
        });
      };
    });

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
          echo "  macbook-pro-m5, macbook-pro-m3"
          echo ""
          echo ""
          echo "Home Manager commands:"
          echo "  home-manager build --flake .#<hostname>          # Build home-manager config"
          echo "  home-manager switch --flake .#<hostname>         # Apply home-manager config"
          echo "  home-manager switch --rollback                   # Rollback to previous config"
          echo ""
          echo "Available Home Manager configurations:"
          echo "  linux, linux-arm, codespaces, codespaces-arm"
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
          codespaces =
            (mkHomeConfiguration {
              system = system;
              username = "codespace";
              homeModule = ./home-manager/codespaces.nix;
            }).activationPackage;
        };
      in
        macosChecks // linuxChecks
    );
  };
}
