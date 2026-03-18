{
  pkgs,
  lib,
  system,
  ...
}: let
  isDarwin = lib.hasInfix "darwin" system;
  pinentryPkg =
    if isDarwin
    then pkgs.pinentry_mac
    else pkgs.pinentry-curses;
in {
  home.packages = with pkgs; [
    gnupg
    pinentryPkg
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
    pinentry.package = pinentryPkg;
    defaultCacheTtl = 28800; # 8 hours
    maxCacheTtl = 86400; # 24 hours
  };
}
