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
        # mago owns PHP diagnostics (see nvim lint.lua); phpactor's overlap
        # with it and false-positive on Laravel/Eloquent magic methods (e.g.
        # Model::firstOrCreate). This must be a config file rather than LSP
        # initializationOptions because phpactor outsources diagnostics to a
        # subprocess that only reads config files.
        ".config/phpactor/phpactor.json".text = ''
          {
            "language_server_worse_reflection.diagnostics.enable": false
          }
        '';
      };

      home.packages = let
        language_servers = [
          pkgs.alejandra
          pkgs.bash-language-server
          pkgs.helm-ls
          pkgs.lua-language-server
          pkgs.mago
          pkgs.markdownlint-cli
          pkgs.nixd
          pkgs.phpactor
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
          pkgs.act
          pkgs.age
          # pkgs.argocd
          pkgs.asciinema
          pkgs.asciinema-agg
          pkgs.bat
          pkgs.bazel_8
          pkgs.blade-formatter
          pkgs.cmake
          pkgs.codex
          pkgs.delta
          pkgs.devcontainer
          pkgs.difftastic
          pkgs.dive
          pkgs.duf
          pkgs.dust
          pkgs.exercism
          pkgs.fd
          pkgs.frankenphp
          pkgs.fzf
          pkgs.gping
          pkgs.graphviz
          pkgs.hyperfine
          pkgs.imagemagick
          pkgs.jjui
          pkgs.jq
          pkgs.just
          pkgs.kind
          pkgs.kubectl
          pkgs.kubernetes-helm
          pkgs.laravel
          pkgs.lazydocker
          pkgs.lua51Packages.lua
          pkgs.luajitPackages.luarocks
          pkgs.neovim
          pkgs.ngrok
          pkgs.nodejs_24
          pkgs.php
          pkgs.php84Packages.composer
          # Xdebug DAP adapter under a stable name for nvim-dap (the store
          # path of the vscode extension changes on every update).
          (pkgs.writeShellScriptBin "php-debug-adapter" ''
            exec ${pkgs.nodejs_24}/bin/node ${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js "$@"
          '')
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

    # macOS-specific fish functions
    (lib.mkIf (lib.hasInfix "darwin" system) {
      # Screenshot location is set via nix-darwin (system.defaults.screencapture);
      # the directory must exist or macOS falls back to the Desktop.
      home.activation.ensureScreenshotsDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "$HOME/Screenshots"
      '';

      programs.fish.functions = {
        clear-message-attachments = {
          description = "Clear Local Message Attachments";
          body = ''
            rm -rf ~/Library/Messages/Attachments/*
            echo "Local Message Attachments have been cleared."
          '';
        };
        dns-cache-flush = {
          description = "Flush DNS Cache";
          body = ''
            sudo dscacheutil -flushcache
            sudo killall -HUP mDNSResponder
            echo "DNS cache has been flushed."
          '';
        };
      };
    })
  ];
}
