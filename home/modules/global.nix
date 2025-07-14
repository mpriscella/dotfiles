{ lib, pkgs, ... }:

{
  config = {
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
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
      kind
      kubectl
      kubernetes-helm
      lazydocker
      lazygit
      neovim
      nil
      ripgrep
      yq
    ];
  };
}
