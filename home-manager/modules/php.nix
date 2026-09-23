{pkgs, ...}: let
  # One interpreter, named once, for everything in this module.
  #
  # nixpkgs' default `php` is still 8.4, so any package taking `php` as an
  # argument builds against 8.4 unless told otherwise — even while php85
  # below is what lands on PATH. That split is not cosmetic: nixpkgs wraps
  # PHP applications with PHP_INI_SCAN_DIR pointing at their own
  # interpreter's ini directory, and the variable is inherited by child
  # processes. So `laravel new` exported 8.4's ini directory, shelled out to
  # `php` from PATH (8.5), and the 8.5 binary tried to load 8.4's modules:
  #
  #   Warning: PHP Startup: zip: Unable to initialize module
  #   Module compiled with module API=20240924   <- 8.4
  #   PHP    compiled with module API=20250925   <- 8.5
  #
  # Every extension failed that check, which left iconv and mbstring
  # missing, and Composer aborted before writing a single file.
  #
  # laravel and phpactor are buildComposerProject2 packages, so overriding
  # them costs a vendor fetch and a rewrap. frankenphp is the expensive one:
  # it does `php.override { embedSupport = true; ztsSupport = true; }`, and
  # pointing that at 8.5 means compiling PHP itself rather than substituting
  # it. Worth it — otherwise the app server runs 8.4 while `php artisan`
  # runs 8.5 — but drop `frankenphp` back to `pkgs.frankenphp` if you would
  # rather not pay for that build today.
  php = pkgs.php85;
in {
  home.file = {
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

  # laravel-cloud-cli and laravel-lsp below are not from nixpkgs — they come
  # from github:mpriscella/nix-packages, applied as an overlay in flake.nix.
  home.packages = [
    # Runtimes and tooling
    php
    php.packages.composer
    (pkgs.frankenphp.override {inherit php;})
    (pkgs.laravel.override {inherit php;})
    pkgs.laravel-cloud-cli
    pkgs.blade-formatter

    # Xdebug DAP adapter under a stable name for nvim-dap (the store
    # path of the vscode extension changes on every update).
    (pkgs.writeShellScriptBin "php-debug-adapter" ''
      exec ${pkgs.nodejs_24}/bin/node ${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js "$@"
    '')

    # Language servers
    pkgs.mago
    (pkgs.phpactor.override {inherit php;})
    pkgs.laravel-lsp
  ];
}
