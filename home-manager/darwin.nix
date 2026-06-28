{
  lib,
  pkgs,
  ...
}: {
  # macOS-only Home Manager config. Imported solely on the nix-darwin build
  # (see mkDarwinConfiguration in flake.nix), so no `system` guard is needed.

  # Packages that only make sense (or only build) on macOS live here rather
  # than in the cross-platform home.nix list:
  #   - container: Apple's container tool, aarch64-darwin only.
  #   - sourcekit-lsp: pulls in Swift, which fails to build on x86_64-linux
  #     (clang rejects the x86-specific -mtls-dialect=gnu2 flag).
  home.packages = [
    pkgs.container
    pkgs.sourcekit-lsp
  ];

  # Screenshot location is set via nix-darwin (system.defaults.screencapture);
  # the directory must exist or macOS falls back to the Desktop. Created as a
  # Home Manager activation (runs as the user) so it is user-owned — a
  # system-level activation would run as root and leave it unwritable.
  home.activation.ensureScreenshotsDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/Screenshots"
  '';

  programs.fish.functions = {
    clear-message-attachments = {
      description = "Clear Local Message Attachments";
      body = ''
        rm -rf ~/Library/Messages/Attachments/*
        echo "Local Message Attachments have been cleared."
      '';
    };
    dns-cache-flush = {
      description = "Flush DNS Cache";
      body = ''
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
        echo "DNS cache has been flushed."
      '';
    };
  };
}
