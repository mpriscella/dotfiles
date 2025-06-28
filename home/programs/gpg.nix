{ config, pkgs, lib, inputs, ... }:

{
  options = {
    gpgConfig = {
      gpgSigningKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "GPG key ID for signing commits";
      };
    };
  };

  config = {
    home.packages = with pkgs; [
      gnupg
      pinentry-curses
    ];

    programs.gpg = {
      enable = true;
      settings = {
        keyid-format = "long";
        with-fingerprint = true;
        no-greeting = true;
        use-agent = true;
      };
    };

    services.gpg-agent = {
      enable = true;
      enableFishIntegration = true;
      pinentry.package = pkgs.pinentry-curses;
      defaultCacheTtl = 28800; # 8 hours
      maxCacheTtl = 86400; # 24 hours
    };
  };
}
