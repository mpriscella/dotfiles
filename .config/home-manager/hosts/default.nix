{ config, pkgs, lib, ... }:

let
  # Automatically detect username from environment
  username = builtins.getEnv "USER";

  # Construct home directory based on detected username and OS
  homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  # Detect hostname for configuration path
  hostname =
    let
      envHostname = builtins.getEnv "HOSTNAME";
    in
    if envHostname != "" then envHostname
    else if builtins.pathExists /etc/hostname then builtins.readFile /etc/hostname
    else "unknown";
in

{
  imports = [
    ../common.nix
    ../modules/machine-config.nix
  ];

  # Automatically inferred values
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.05";

  # Custom configuration using our module
  myConfig = {
    configPath = "${homeDirectory}/.config/home-manager/hosts/default.nix";
    # Default GPG key (optional - can be left null for no signing)
    gpgSigningKey = null; # Set to your default key ID if desired
  };

  # Optional: Add some debug info to session variables
  home.sessionVariables = {
    HM_DETECTED_USER = username;
    HM_DETECTED_HOME = homeDirectory;
    HM_DETECTED_HOST = hostname;
  };
}
