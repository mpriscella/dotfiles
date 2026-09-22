# Minimal profile for GitHub Codespaces / generic dev containers.
#
# Used instead of home.nix (not alongside it) — see `homeModule` in
# mkHomeConfiguration. The goal is the editor and a shell that feels like
# home, and nothing that depends on this machine being *mine*:
#
#   - No sops/age: the decryption key never leaves the laptop, so any module
#     that reads a secret is out (sops.nix, mcp.nix, and the fish snippet that
#     exports GITHUB_MCP_TOKEN, guarded in programs/fish.nix).
#   - No GPG: there's no signing key in an ephemeral container, so git and jj
#     signing are forced off below rather than failing every commit.
#   - No cloud/infra tooling (aws, k9s, kubectl, gcloud), no PHP/Laravel
#     toolchain, no media tools. Add ./modules/php.nix to the imports if a
#     Codespace ever needs it.
#   - No nh.nix: NH_FLAKE would point at a checkout path that doesn't exist
#     here.
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./modules/neovim.nix

    ./programs/direnv.nix
    ./programs/eza.nix
    ./programs/fish.nix
    ./programs/gh.nix
    ./programs/git.nix
    ./programs/jujutsu.nix
    ./programs/starship.nix
    ./programs/zoxide.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Nothing to sign with here. Both modules otherwise default gpgsign on and
  # resolve a key from the committer email (see programs/git.nix).
  programs.git.settings.commit.gpgsign = lib.mkForce false;
  programs.git.settings.tag.gpgsign = lib.mkForce false;
  programs.jujutsu.settings.signing.behavior = lib.mkForce "drop";

  home.file.".config/nix/nix.conf".text = ''
    experimental-features = nix-command flakes
    warn-dirty = false
  '';

  home.packages = [
    # `cat` is aliased to bat in programs/fish.nix, and git.nix sets
    # core.pager/interactive.diffFilter to delta — both must be on PATH or the
    # shell and git break.
    pkgs.bat
    pkgs.delta

    # nvim-treesitter compiles parsers at runtime and needs a C compiler. The
    # Codespaces universal image ships one, but a slimmer devcontainer base
    # (node, python-only) may not.
    pkgs.gcc

    # Pickers (snacks), grep, and conform's prettierd formatter.
    pkgs.fd
    pkgs.fzf
    pkgs.prettierd
    pkgs.ripgrep

    pkgs.jq
    pkgs.yq
  ];

  home.sessionVariables = {
    PAGER = "less";
    LESS = "-R";
  };

  programs.man.enable = true;
  programs.home-manager.enable = true;
}
