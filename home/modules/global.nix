{ lib, nixpkgs, ... }:

{
  options.gpgConfig.gpgSigningKey = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "GPG key ID for signing commits";
  };

  config = {
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with nixpkgs; [
      ack
      act
      # atuin
      bat
      cargo
      # delta
      dive
      fd
      fzf
      # gh
      graphviz
      jq
      kind
      kubectl
      kubernetes-helm
      lazydocker
      # lazygit
      neovim
      nodejs_24
      ripgrep
      yq
    ];
  };
}
