{ config, pkgs, lib, inputs, ... }:

{
  config = {
    # Fish shell configuration
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/fish.nix
    programs.fish = {
      enable = true;

      shellInit = ''
        # Set up direnv if available
        if command -v direnv >/dev/null
          direnv hook fish | source
        end

        fish_vi_key_bindings
      '';

      shellAliases = {
        # Modern replacements
        cat = "bat --style=plain";
        find = "fd";
        grep = "rg";

        lg = "lazygit";
      };

      plugins = [
        {
          name = "pure";
          src = pkgs.fishPlugins.pure.src;
        }
      ];
    };
  };
}
