# TODO: How do I update this
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
# Laravel language server (https://github.com/laravel-ls/laravel-ls). Provides
# blade component completion (`<x-...>`), argument completion, hover, and
# missing-component diagnostics.
buildGoModule rec {
  pname = "laravel-ls";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "laravel-ls";
    repo = "laravel-ls";
    rev = "v${version}";
    hash = "sha256-RR3qYi8Lyx+z+KmpQj456P5youINDxQzfv9cyhrywEs=";
  };

  # The vendored tree-sitter grammar bindings (blade, php, html, dotenv) `#include`
  # generated C sources (`src/parser.c`) that live outside their Go package dir,
  # which `go mod vendor` drops. proxyVendor keeps the full module tree so cgo
  # can find them. vendorHash differs from the vendored-tree hash as a result.
  proxyVendor = true;
  vendorHash = "sha256-fWbB4FclmSnfQxKFetn5RCPY1jlsm7PeO3VFAZresr4=";

  subPackages = ["cmd/laravel-ls"];

  meta = {
    description = "Laravel language server written in Go";
    homepage = "https://github.com/laravel-ls/laravel-ls";
    license = lib.licenses.mit;
    mainProgram = "laravel-ls";
  };
}
