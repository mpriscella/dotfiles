# https://github.com/nix-community/home-manager/blob/master/modules/programs/claude-code.nix
{...}: {
  programs.claude-code = {
    enable = true;

    enableMcpIntegration = true;
  };
}
