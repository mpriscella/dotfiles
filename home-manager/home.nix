{
  config,
  pkgs,
  lib,
  inputs,
  system,
  isDarwinModule ? false,
  ...
}: {
  imports = [
    # Modules
    ./modules/php.nix

    # Programs
    ./programs/act.nix
    ./programs/atuin.nix
    ./programs/aws.nix
    ./programs/claude-code.nix
    ./programs/direnv.nix
    ./programs/eza.nix
    ./programs/fish.nix
    ./programs/gh.nix
    ./programs/git.nix
    ./programs/gpg.nix
    ./programs/jujutsu.nix
    ./programs/k9s.nix
    ./programs/mcp.nix
    ./programs/nh.nix
    ./programs/opencode.nix
    ./programs/sops.nix
    ./programs/starship.nix
    ./programs/tmux.nix
    ./programs/yazi.nix
    ./programs/yt-dlp.nix
    ./programs/zoxide.nix
  ];

  config = lib.mkMerge [
    # Only set nixpkgs config when not using nix-darwin (standalone Home
    # Manager).
    (lib.mkIf (!isDarwinModule) {
      nixpkgs.config.allowUnfree = true;
    })

    {
      home.file = {
        ".ackrc".text = ''
          --pager=less -R
          --ignore-case
        '';
        ".config/ghostty".source = ../config/ghostty;
        ".config/nix/nix.conf".text = ''
          # On macOS nix-darwin also sets experimental-features system-wide;
          # this covers standalone Linux home-manager (upstream Nix doesn't
          # enable flakes by default).
          experimental-features = nix-command flakes
          warn-dirty = false
        '';
        ".config/nvim".source = ../config/nvim;
      };

      home.packages = let
        # neovim tracks nixpkgs-unstable directly rather than the pinned
        # weekly nixpkgs snapshot used for everything else.
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
          pkgs.sourcekit-lsp
          pkgs.tailwindcss-language-server
          pkgs.terraform-ls
          pkgs.tree-sitter
          pkgs.typescript-language-server
          pkgs.zls
        ];
        packages = [
          pkgs.ack
          pkgs.age
          pkgs.asciinema
          pkgs.asciinema-agg
          pkgs.bat
          # pkgs.bazel_8
          pkgs.cmake
          pkgs.codex
          pkgs.container
          pkgs.delta
          pkgs.devcontainer
          pkgs.difftastic
          pkgs.dive
          pkgs.duf
          pkgs.dust
          pkgs.exercism
          pkgs.fd
          pkgs.fzf
          pkgs.go
          pkgs.gping
          pkgs.graphviz
          pkgs.hyperfine
          pkgs.imagemagick
          pkgs.jjui
          pkgs.jq
          pkgs.just
          pkgs.kind
          pkgs.kubectl
          pkgs-unstable.kubernetes-helm
          pkgs.lazydocker
          pkgs.lua51Packages.lua
          pkgs.luajitPackages.luarocks
          pkgs-unstable.neovim
          pkgs.ngrok
          pkgs.nodejs_24
          pkgs.ollama
          pkgs.pnpm
          pkgs.prettierd
          pkgs.ripgrep
          pkgs.sops
          pkgs.typescript
          pkgs.uv
          pkgs.yarn
          pkgs.yq
          pkgs.zig
        ];
      in
        packages ++ language_servers;

      home.sessionVariables = {
        EDITOR = "nvim";
        PAGER = "less";
        LESS = "-R";
      };

      programs.man.enable = true;
      programs.home-manager.enable = true;
    }
  ];
}
