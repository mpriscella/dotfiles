{ config, lib, pkgs, ... }:

with lib;

{
  options.myConfig = {
    configPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config/home-manager/home.nix";
      description = "Path to the home-manager configuration file for this machine";
    };

    gpgSigningKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "GPG key ID for signing git commits on this machine";
      example = "ABC123DEF456";
    };
  };

  config = {
    # Use your custom options here
    home.packages = with pkgs; [
      # Custom build script
      (writeShellScriptBin "home-manager-build" ''
        echo "Building Home Manager configuration..."
        echo "Using config: ${config.myConfig.configPath}"
        exec home-manager build --file "${config.myConfig.configPath}" "$@"
      '')

      # Custom switch script
      (writeShellScriptBin "home-manager-switch" ''
        echo "Switching Home Manager configuration..."
        echo "Using config: ${config.myConfig.configPath}"
        exec home-manager switch --file "${config.myConfig.configPath}" "$@"
      '')
    ];
  };
}
