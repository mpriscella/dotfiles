{
  pkgs,
  lib,
  gpgSigningKey,
  userConfig,
  ...
}: {
  programs.jujutsu = {
    enable = true;

    settings = lib.mkMerge [
      {
        git = {
          auto-track-bookmarks = "main";
          fetch-tags = true;
        };
        template-aliases = {
          "format_timestamp(timestamp)" = "timestamp.ago()";
        };
        templates = {
          "git_push_bookmark" = ''"mpriscella/push-" ++ change_id.short()'';
        };
        user = {
          name = userConfig.name;
          email = userConfig.email;
        };
        ui = {
          default-command = "log";
          diff-formatter = ["${pkgs.difftastic}/bin/difft" "--color=always" "$left" "$right"];
          editor = "nvim";
          paginate = "never";
        };
      }

      {
        # See git.nix: prefer an explicit key ID, else let GPG resolve the key
        # from the committer email so an install-time generated key is used.
        signing = {
          behavior = "own";
          backend = "gpg";
          key =
            if (gpgSigningKey != null && gpgSigningKey != "")
            then gpgSigningKey
            else userConfig.email;
          backends.gpg.program = "${pkgs.gnupg}/bin/gpg";
        };
      }
    ];
  };
}
