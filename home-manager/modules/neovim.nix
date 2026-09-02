{
  pkgs,
  inputs,
  system,
  ...
}: let
  # neovim tracks nixpkgs-unstable directly rather than the pinned weekly
  # nixpkgs snapshot used for everything else.
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  language_servers = [
    pkgs.alejandra
    pkgs.bash-language-server
    pkgs.emmet-language-server
    pkgs.gopls
    pkgs.helm-ls
    pkgs.lua-language-server
    pkgs.markdownlint-cli
    pkgs.nixd
    pkgs.python313Packages.python-lsp-server
    pkgs.shellcheck
    pkgs.tailwindcss-language-server
    pkgs.terraform-ls
    pkgs.tflint
    pkgs.tree-sitter
    pkgs.typescript-language-server
    pkgs.vue-language-server
    pkgs.yaml-language-server
    pkgs.zls
  ];
in {
  # Linked in from the Nix store rather than symlinked to a checkout, so the
  # config works on any host this flake is applied to — including one that has
  # no clone of this repo (`home-manager switch --flake github:...`) or one
  # that cloned it somewhere unexpected. An out-of-store symlink to a fixed
  # path would silently dangle there, and Neovim would start with no config at
  # all rather than failing.
  #
  # The cost is that edits under config/nvim need a rebuild to take effect.
  # `nix develop` provides `nvim-dev`, which runs Neovim against the working
  # tree instead — that is the loop for iterating on the config, and the place
  # to run `:Lazy update`, since it can write `lazy-lock.json` back to the
  # checkout.
  home.file.".config/nvim" = {
    source = ../../config/nvim;
    # Per-file links rather than one symlink to the store directory, so
    # ~/.config/nvim is itself a real writable directory and Neovim can create
    # state inside it. The tracked files stay read-only.
    recursive = true;
  };

  home.packages = [pkgs-unstable.neovim] ++ language_servers;

  home.sessionVariables.EDITOR = "nvim";
}
