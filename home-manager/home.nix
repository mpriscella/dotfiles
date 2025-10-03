{
  config,
  pkgs,
  lib,
  inputs,
  gpgSigningKey ? null,
  isDarwinModule ? false,
  ...
}: {
  imports = [
    ./programs/atuin.nix
    ./programs/aws.nix
    ./programs/direnv.nix
    ./programs/fish.nix
    ./programs/gh.nix
    (
      import ./programs/git.nix {
        inherit config pkgs lib inputs gpgSigningKey;
      }
    )
    ./programs/gpg.nix
    (
      import ./programs/jujutsu.nix {
        inherit config pkgs lib inputs gpgSigningKey;
      }
    )
    ./programs/k9s.nix
    ./programs/starship.nix
    ./programs/tmux.nix
    ./programs/yt-dlp.nix
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
      ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${inputs.self}/config/nvim";
    };

    home.packages = [
      pkgs.ack
      pkgs.act
      pkgs.argocd
      pkgs.asciinema
      pkgs.asciinema-agg
      pkgs.atuin
      pkgs.bat
      pkgs.bazel_8
      pkgs.cmake
      pkgs.delta
      pkgs.dive
      pkgs.exercism
      pkgs.fd
      pkgs.fzf
      pkgs.github-copilot-cli
      pkgs.graphviz
      pkgs.jq
      pkgs.just
      pkgs.kind
      pkgs.kubectl
      pkgs.kubernetes-helm
      pkgs.lazydocker
      pkgs.lazygit
      pkgs.opencode
      pkgs.neovim
      pkgs.nil
      pkgs.nodejs_24
      pkgs.ripgrep
      pkgs.uv
      pkgs.yarn
      pkgs.yq
      pkgs.zig_0_15
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      PAGER = "less";
      LESS = "-R";
    };

    programs.man.enable = true;
    programs.home-manager.enable = true;

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
    }
  ];
}
