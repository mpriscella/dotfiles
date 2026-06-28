{
  pkgs,
  lib,
  gpgSigningKey,
  userConfig,
  ...
}: {
  programs.git = {
    enable = true;

    settings = lib.mkMerge [
      {
        aliases = {
          chb = "checkout -b";
          dft = "difftool --tool difftastic";
        };

        difftool.difftastic.cmd = "${pkgs.difftastic}/bin/difft \"$LOCAL\" \"$REMOTE\"";
        difftool.prompt = false;

        user = {
          name = userConfig.name;
          email = userConfig.email;
        };

        init.defaultBranch = "main";
        pull.rebase = false;
        push.autoSetupRemote = true;
        core.editor = "nvim";

        diff.tool = "vimdiff";
        merge.tool = "vimdiff";

        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
        };
        merge.conflictstyle = "zdiff3";
      }

      {
        # Prefer an explicit per-host key ID when provided; otherwise sign with
        # the key GPG resolves from the committer email. This decouples signing
        # from any hardcoded fingerprint, so a key generated at install time
        # (see install.sh) is picked up without a rebuild.
        user.signingkey =
          if (gpgSigningKey != null && gpgSigningKey != "")
          then gpgSigningKey
          else userConfig.email;
        commit.gpgsign = true;
        tag.gpgsign = true;
        gpg.program = "${pkgs.gnupg}/bin/gpg";
      }
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
