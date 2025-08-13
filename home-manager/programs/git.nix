{ config, pkgs, lib, inputs, gpgSigningKey ? null, ... }:

{
  programs.git = {
    enable = true;
    userName = "Mike Priscella";
    userEmail = "mpriscella@gmail.com";

    extraConfig = lib.mkMerge [
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

        # Delta
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
        };
        merge.conflictstyle = "zdiff3";
      }

      (lib.optionalAttrs (gpgSigningKey != null) {
        user.signingkey = gpgSigningKey;
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
  };
}
