{ config, pkgs, lib, inputs, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      set -gx PATH $HOME/.local/state/nix/profiles/home-manager/home-path/bin $PATH
      echo "DEBUG: PATH at shell startup: $PATH"

      # Remove Atuin functions if atuin is not available
      if not type -q atuin
        functions -e _atuin_preexec
        functions -e _atuin_postexec
      end

      # Set up direnv if available
      if command -v direnv >/dev/null
        direnv hook fish | source
      end

      if type -q atuin
        atuin init fish | source
      end

      fish_vi_key_bindings
    '';

    interactiveShellInit = "";

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
}
