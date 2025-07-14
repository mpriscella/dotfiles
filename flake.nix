{
  description = "Personal dotfiles with Home Manager and nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager }:
    {
      darwinConfigurations = {
        "macbook-pro-m3" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./home/modules/global.nix
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

                gpgConfig = {
                  gpgSigningKey = "799887D03FE96FD0";
                };
              };
            }
          ];
        };
      };
    };
}
