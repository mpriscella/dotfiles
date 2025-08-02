{
  description = "Personal dotfiles with Home Manager and nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    home-manager-config.url = "github:mpriscella/nix-home-manager";
    home-manager-config.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-config.inputs.home-manager.follows = "home-manager";

    # Pin to Lua 5.1.x.
    lua51.url = "github:NixOS/nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, home-manager-config, lua51 }:
    let
      mkPackagesFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      defaultPackages = pkgs: [
        pkgs.ack
        pkgs.act
        pkgs.atuin
        pkgs.bat
        pkgs.delta
        pkgs.dive
        pkgs.fd
        pkgs.fzf
        pkgs.gh
        pkgs.graphviz
        pkgs.jq
        pkgs.just
        pkgs.kind
        pkgs.kubectl
        pkgs.kubernetes-helm
        pkgs.lazydocker
        pkgs.lazygit
        pkgs.opencode
        pkgs.neovim
        pkgs.nil
        pkgs.nodejs_24
        pkgs.ripgrep
        pkgs.yq
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
              home-manager.users.michaelpriscella = nixpkgs.lib.mkMerge [
                (home-manager-config.lib.mkHomeConfiguration {
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
            ./home/modules/darwin.nix
            {
              users.users.mpriscella = {
                name = "mpriscella";
                home = "/Users/mpriscella";
              };
            }
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.mpriscella = nixpkgs.lib.mkMerge [
                (home-manager-config.lib.mkHomeConfiguration {
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

      devShells.aarch64-darwin.default =
        let
          pkgs = mkPackagesFor "aarch64-darwin";
        in
        pkgs.mkShell {
          buildInputs = (defaultPackages pkgs) ++ [
            nix-darwin.packages.aarch64-darwin.darwin-rebuild
            (pkgs.writeShellScriptBin "nvim-dev" ''
              CONFIG_DIR="$(pwd)/.config/nvim"
              DATA_DIR="$(pwd)/nvim-data"
              CACHE_DIR="$(pwd)/nvim-cache"

              mkdir -p "$DATA_DIR" "$CACHE_DIR"

              XDG_CONFIG_HOME="$CONFIG_DIR" \
                XDG_DATA_HOME="$DATA_DIR" \
                XDG_CACHE_HOME="$CACHE_DIR" \
                nvim -u "$CONFIG_DIR/init.lua" \
                  --cmd "set runtimepath^=$CONFIG_DIR" \
                  --cmd "lua package.path = '$CONFIG_DIR/lua/?.lua;$CONFIG_DIR/lua/?/init.lua;' .. package.path" \
                  "$@"
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
            echo "Available commands:"
            echo "  darwin-rebuild switch --flake .#<hostname>  # Apply system config"
            echo "  nix flake update                            # Update dependencies"
            echo "  nix fmt flake.nix home/                     # Format code"
            echo "  nvim-dev [files]                            # Neovim with isolated config"
          '';
        };

      formatter.aarch64-darwin = (mkPackagesFor "aarch64-darwin").nixpkgs-fmt;
    };
}
