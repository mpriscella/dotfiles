{
  description = "Personal dotfiles with Home Manager and nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager }:
    let
      mkPackagesFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      defaultPackages = pkgs: with pkgs; [
        ack
        act
        atuin
        bat
        delta
        dive
        fd
        fzf
        gh
        graphviz
        jq
        just
        kind
        kubectl
        kubernetes-helm
        lazydocker
        lazygit
        neovim
        nil
        nodejs_24
        ripgrep
        yq
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
              home-manager.users.michaelpriscella = {
                home.stateVersion = "24.05";
                imports = [
                  ./home/modules/home-base.nix
                ];

                home.packages = defaultPackages (mkPackagesFor "aarch64-darwin");

                gpgConfig = {
                  gpgSigningKey = "799887D03FE96FD0";
                };
              };
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
              home-manager.users.mpriscella = {
                home.stateVersion = "24.05";
                imports = [
                  ./home/modules/home-base.nix
                ];

                home.packages = defaultPackages (mkPackagesFor "aarch64-darwin");

                gpgConfig = {
                  gpgSigningKey = "27301C740482A8B1";
                };
              };
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

              XDG_CONFIG_HOME="$(pwd)/.config/nvim" \
              XDG_DATA_HOME="$DATA_DIR" \
              XDG_CACHE_HOME="$CACHE_DIR" \
                nvim -u "$CONFIG_DIR/init.lua" \
                     --cmd "set runtimepath^=$CONFIG_DIR" \
                     --cmd "lua package.path = '$CONFIG_DIR/lua/?.lua;$CONFIG_DIR/lua/?/init.lua;' .. package.path" \
                     "$@"
            '')
          ];

          shellHook = ''
            echo "🎯 Dotfiles Development Environment"
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
