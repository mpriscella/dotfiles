{ config, pkgs, lib, ... }:

{
  options.myPackages = {
    cli = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        ack
        act
        bat
        dive
        fd
        fzf
        ripgrep
        jq
        yq
      ];
      description = "Common CLI tools";
    };

    kubernetes = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        kind
        k9s
        kubectl
        kubernetes-helm
      ];
      description = "Kubernetes tools";
    };

    development = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        neovim
        nodejs_24
        git
        lazydocker
        graphviz
      ];
      description = "Development tools";
    };

    all = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = config.myPackages.cli ++ config.myPackages.kubernetes ++ config.myPackages.development;
      description = "All packages combined";
    };
  };

  config = {
    home.packages = config.myPackages.all;
  };
}
