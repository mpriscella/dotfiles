{pkgs, ...}: {
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

  home.packages = [
    # Runtimes and tooling
    pkgs.php
    pkgs.php84Packages.composer
    pkgs.frankenphp
    pkgs.laravel
    pkgs.blade-formatter

    # Xdebug DAP adapter under a stable name for nvim-dap (the store
    # path of the vscode extension changes on every update).
    (pkgs.writeShellScriptBin "php-debug-adapter" ''
      exec ${pkgs.nodejs_24}/bin/node ${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js "$@"
    '')

    # Language servers
    pkgs.mago
    pkgs.phpactor
    (pkgs.callPackage ../pkgs/laravel-lsp.nix {})
  ];
}
