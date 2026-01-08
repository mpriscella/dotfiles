{
  pkgs,
  lib,
  gpgSigningKey,
  ...
}: {
  programs.jujutsu = {
    enable = true;

    # Disable pager
    settings = lib.mkMerge [
      {
        template-aliases = {
          "format_timestamp(timestamp)" = "timestamp.ago()";
        };
        templates = {
          "git_push_bookmark" = ''"mpriscella/push-" ++ change_id.short()'';
        };
        user = {
          name = "Mike Priscella";
          email = "mpriscella@gmail.com";
        };
        ui = {
          default-command = "log";
          editor = "nvim";
          paginate = "never";
        };
      }

      (lib.optionalAttrs (gpgSigningKey != null && gpgSigningKey != "") {
        signing = {
          behavior = "own";
          backend = "gpg";
          key = gpgSigningKey;
          backends.gpg.program = "${pkgs.gnupg}/bin/gpg";
        };
      })
    ];
  };
}
