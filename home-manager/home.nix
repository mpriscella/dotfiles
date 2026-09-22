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
    ./modules/neovim.nix
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
        # From the store, not a symlink to the checkout — see the note in
        # ./modules/neovim.nix. Applying this flake on a host with no clone (or
        # a clone at an unexpected path) would otherwise leave a dangling
        # symlink here and silently fall back to stock Ghostty defaults.
        ".config/ghostty".source = ../config/ghostty;
        ".config/nix/nix.conf".text = ''
          # On macOS nix-darwin also sets experimental-features system-wide;
          # this covers standalone Linux home-manager (upstream Nix doesn't
          # enable flakes by default).
          experimental-features = nix-command flakes
          warn-dirty = false
        '';
      };

      home.packages = let
        pkgs-unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      in [
        pkgs.ack
        pkgs.age
        pkgs.asciinema
        pkgs.asciinema-agg
        pkgs.bat
        pkgs.cmake
        pkgs-unstable.codex
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
        pkgs.google-cloud-sdk
        pkgs.gping
        pkgs.hyperfine
        pkgs.imagemagick
        pkgs.jjui
        pkgs.jq
        pkgs.just
        pkgs.kind
        pkgs.kubectl
        pkgs.kubernetes-helm
        # Provides lldb-dap, the DAP adapter nvim-dap uses for Zig.
        pkgs.lldb
        pkgs.lua51Packages.lua
        pkgs.luajitPackages.luarocks
        pkgs.mermaid-cli
        pkgs.ngrok
        pkgs.nodejs_26
        pkgs.pnpm
        pkgs.prettierd
        pkgs.ripgrep
        pkgs.sops
        pkgs.terraform
        pkgs.typescript
        pkgs.uv
        pkgs.yarn
        pkgs.yq
        pkgs.zig
      ];

      home.sessionVariables = {
        PAGER = "less";
        LESS = "-R";
      };

      # `nix flake init -t templates#<name>` instead of spelling out the
      # full github: URL. Templates live in mpriscella/nix-templates.
      nix.registry.templates.to = {
        type = "github";
        owner = "mpriscella";
        repo = "nix-templates";
      };

      programs.man.enable = true;
      programs.home-manager.enable = true;
    }
  ];
}
