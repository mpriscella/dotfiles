{
  pkgs,
  lib,
  gpgSigningKey,
  ...
}: {
  programs.git = {
    enable = true;

    settings = lib.mkMerge [
      {
        aliases = {
          chb = "checkout -b";
        };

        user = {
          name = "Mike Priscella";
          email = "mpriscella@gmail.com";
        };

        init.defaultBranch = "main";
        pull.rebase = false;
        push.autoSetupRemote = true;
        core.editor = "nvim";

        flake.warn-dirty = false;

        diff.tool = "vimdiff";
        merge.tool = "vimdiff";

        core.preloadindex = true;
        core.fscache = true;
        gc.auto = 256;

        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
        };
        merge.conflictstyle = "zdiff3";
      }

      (lib.optionalAttrs (gpgSigningKey != null && gpgSigningKey != "") {
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
  };
}
