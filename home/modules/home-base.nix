{ config, pkgs, lib, ... }:

{
  options.gpgConfig.gpgSigningKey = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "GPG key ID for signing commits";
  };

  imports = [
    ../programs/atuin.nix
    ../programs/aws.nix
    ../programs/direnv.nix
    ../programs/fish.nix
    ../programs/git.nix
    ../programs/gpg.nix
    ../programs/k9s.nix
    ../programs/tmux.nix
    ../programs/yt-dlp.nix
  ];

  config = {
    home.file = {
      ".ackrc".text = ''
        --pager=less -R
        --ignore-case
      '';
      ".config/ghostty".source = ../../.config/ghostty;
      ".config/nvim".source = ../../.config/nvim;
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      PAGER = "less";
      LESS = "-R";
    };

    programs.man.enable = true;

    programs.fish.functions = {
      dns-cache-purge = {
        description = "Purge DNS Cache";
        body = ''
          sudo dscacheutil -flushcache
          sudo killall -HUP mDNSResponder
        '';
      };
    };
  };
}
