{ config, pkgs, lib, inputs, ... }:

{
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

      (lib.optionalAttrs (config.gpgConfig.gpgSigningKey != null) {
        user.signingkey = config.gpgConfig.gpgSigningKey;
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
