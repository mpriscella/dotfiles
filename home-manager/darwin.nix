{lib, ...}: {
  # macOS-only Home Manager config. Imported solely on the nix-darwin build
  # (see mkDarwinConfiguration in flake.nix), so no `system` guard is needed.

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
