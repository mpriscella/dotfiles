{ config, pkgs, lib, inputs, ... }:

{
  programs.fish = {
    enable = true;

    # Why do these paths need to be set manually and aren't inferred by home-manager?
    shellInit = ''
      set -gx PATH $HOME/.local/state/nix/profiles/home-manager/home-path/bin $PATH
      set -gx PATH /nix/var/nix/profiles/default/bin $PATH

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

    shellAliases = {
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
