{
  config,
  pkgs,
  lib,
  inputs,
  gpgSigningKey ? null,
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

      (lib.optionalAttrs (gpgSigningKey != null) {
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
