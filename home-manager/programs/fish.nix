{config, ...}: {
  programs.fish = {
    enable = true;

    shellAliases = {
      cat = "bat";
      lg = "lazygit";
    };

    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings

      # Load sops secrets as environment variables
      if test -r ${config.sops.secrets.github_mcp_token.path}
        set -gx GITHUB_MCP_TOKEN (cat ${config.sops.secrets.github_mcp_token.path})
      end
    '';
  };

  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];
}
