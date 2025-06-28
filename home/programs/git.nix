{ config, pkgs, lib, inputs, ... }:

{
  options = {
    myGit = {
      gpgSigningKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "GPG key ID for signing commits";
      };
    };
  };

  config = {
    programs.git = {
      enable = true;
      userName = "Mike Priscella";
      userEmail = "mpriscella@gmail.com";

      extraConfig = lib.mkMerge [
        # Base configuration
        {
          init.defaultBranch = "main";
          pull.rebase = false;
          push.autoSetupRemote = true;
          core.editor = "nvim";

          # Disable dirty worktree warnings for flake operations
          flake.warn-dirty = false;

          # Better diff and merge tools
          diff.tool = "vimdiff";
          merge.tool = "vimdiff";

          # Performance optimizations
          core.preloadindex = true;
          core.fscache = true;
          gc.auto = 256;
        }

        (lib.optionalAttrs (config.myGit.gpgSigningKey != null) {
          user.signingkey = config.myGit.gpgSigningKey;
          commit.gpgsign = true;
          tag.gpgsign = true;
          gpg.program = "${pkgs.gnupg}/bin/gpg";
        })
      ];

      ignores = [
        ".DS_Store"
        ".direnv/"
        "*.log"
        ".env"
        ".env.local"
        "node_modules/"
        ".next/"
        "dist/"
        "build/"
      ];

      aliases = {
        chb = "checkout -b";
      };

      delta = {
        enable = true;
        options = {
          navigate = true;
          light = false;
          side-by-side = true;
          line-numbers = true;
          syntax-theme = "Dracula";
        };
      };

      lfs.enable = true;
    };

    home.packages = with pkgs; [
      delta
      gh
      lazygit
    ];
  };
}
