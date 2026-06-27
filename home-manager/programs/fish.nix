{
  config,
  lib,
  system,
  ...
}: {
  programs.fish = {
    enable = true;

    # cat is always bat, so an alias (the substitution shouldn't be visible).
    shellAliases = {
      cat = "bat";
    };

    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings

      # Load sops secrets as environment variables
      if test -r ${config.sops.secrets.github_mcp_token.path}
        set -gx GITHUB_MCP_TOKEN (cat ${config.sops.secrets.github_mcp_token.path})
      end
    '';
  };

  # macOS Homebrew paths, plus the Ghostty app bundle (the CLI lives inside
  # the bundle and is not symlinked onto the PATH at install).
  home.sessionPath = lib.mkIf (lib.hasInfix "darwin" system) [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/Applications/Ghostty.app/Contents/MacOS"
  ];
}
