# Exposed as `packages.<system>.laravel-lsp` in flake.nix. To update: run
# `nix-update --flake laravel-lsp` (available in the dev shell) — it finds the
# latest GitHub release and refreshes version and src hash. Verify with
# `nix build .#laravel-lsp`.
{
  lib,
  stdenvNoCC,
  fetchurl,
  php,
  makeWrapper,
}:
# Official Laravel language server (https://github.com/laravel/lsp). Provides
# framework-aware completions, hover, diagnostics, document links, go-to
# definition, and quick fixes for Laravel and Blade (routes, views, config,
# env, translations, Inertia, Livewire, policies, validation, …). Speaks LSP
# over stdio.
#
# Upstream ships a self-contained ~28MB box PHAR (bundles `vendor`), committed
# to the repo at `builds/laravel-lsp` and symlinked as the `laravel-lsp` bin on
# `composer global require`. We fetch that prebuilt PHAR rather than rebuilding
# from source (which would need box + a full composer install). The only
# runtime requirement is a PHP >= 8.2 interpreter.
#
# Two things fight the read-only Nix store, both fixed below:
#   1. The app's AppServiceProvider hardwires its log dir to
#      `dirname(Phar::running()) . '/logs'` *when running as a PHAR* — a store
#      path — and `ensureDirectoryExists()` on it aborts boot. Only its
#      non-PHAR branch uses the (env-overridable) storage_path(). So we extract
#      the PHAR at build time and run the plain `server` entrypoint, which
#      makes Phar::running() false and takes that fallback.
#   2. With #1 in place, storage_path() drives logs/cache. laravel-zero honors
#      $LARAVEL_STORAGE_PATH (foundation Application::storagePath), so the
#      wrapper points it at a per-user cache dir and pre-creates the skeleton
#      the framework expects. $XDG_CACHE_HOME/$HOME resolve at wrapper runtime.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "laravel-lsp";
  version = "0.0.29";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/laravel/lsp/v${finalAttrs.version}/builds/laravel-lsp";
    hash = "sha256-TpW/lqUidM685dqFn95/bFmy451CbpVmS6xgVm8fEU8=";
  };

  dontUnpack = true;

  nativeBuildInputs = [makeWrapper php];

  installPhase = ''
    runHook preInstall

    # Phar's constructor requires a recognised extension; the fetched src has
    # none, so extract via a .phar-named symlink.
    ln -s $src laravel-lsp.phar
    mkdir -p $out/share/laravel-lsp
    php -r '(new Phar($argv[1]))->extractTo($argv[2], null, true);' \
      laravel-lsp.phar $out/share/laravel-lsp

    makeWrapper ${lib.getExe php} $out/bin/laravel-lsp \
      --add-flags $out/share/laravel-lsp/server \
      --run 'export LARAVEL_STORAGE_PATH="''${XDG_CACHE_HOME:-''$HOME/.cache}/laravel-lsp"' \
      --run 'mkdir -p "''$LARAVEL_STORAGE_PATH"/framework/{cache/data,views,sessions} "''$LARAVEL_STORAGE_PATH"/{app/public,logs}'

    runHook postInstall
  '';

  meta = {
    description = "Official Laravel language server (prebuilt PHAR)";
    homepage = "https://github.com/laravel/lsp";
    license = lib.licenses.mit;
    mainProgram = "laravel-lsp";
  };
})
