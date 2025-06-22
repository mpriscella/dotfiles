{ config, lib, pkgs, inputs, ... }:

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
      # Custom build script for flake
      (writeShellScriptBin "home-manager-build" ''
        echo "Building Home Manager flake configuration..."
        echo "Using config: ${config.myConfig.configPath}"
        cd ${config.home.homeDirectory}/.config/home-manager/../../..
        exec home-manager build --flake .#$(hostname -s || echo "default") "$@"
      '')

      # Custom switch script for flake
      (writeShellScriptBin "home-manager-switch" ''
        echo "Switching Home Manager flake configuration..."
        echo "Using config: ${config.myConfig.configPath}"
        cd ${config.home.homeDirectory}/.config/home-manager/../../..
        exec home-manager switch --flake .#$(hostname -s || echo "default") "$@"
      '')

      # Helper script to show available flake configurations
      (writeShellScriptBin "home-manager-list" ''
        echo "Available Home Manager flake configurations:"
        cd ${config.home.homeDirectory}/.config/home-manager/../../..
        nix flake show . 2>/dev/null | grep homeConfigurations || echo "No configurations found"
      '')

      # Update flake script
      (writeShellScriptBin "home-manager-update" ''
        echo "Updating Home Manager flake inputs..."
        cd ${config.home.homeDirectory}/.config/home-manager/../../..
        nix flake update
        echo "Flake inputs updated!"
      '')
    ];

    # Add some useful shell aliases for flake management
    programs.fish.shellAliases = lib.mkMerge [
      {
        hmb = "home-manager-build";
        hms = "home-manager-switch";
        hml = "home-manager-list";
        hmu = "home-manager-update";
      }
    ];
  };
}
