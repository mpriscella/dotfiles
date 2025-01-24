{
  description = "A flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  # outputs = { self, nixpkgs }: {
  #   packages = {
  #     aarch64-darwin = let
  #       pkgs = import nixpkgs {
  #         config = {
  #           allowUnfree = true;
  #         };
  #         system = "aarch64-darwin";
  #       };
  #     in {
  #       shellcheck = pkgs.shellcheck;
  #       terraform = pkgs.terraform;
  #     };
  #   };
  # };

  outputs = { self, nixpkgs }: {
    defaultPackage.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.terraform_1_10_3;
  };
}
