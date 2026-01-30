# https://github.com/nix-community/home-manager/blob/master/modules/programs/mcp.nix
{...}: {
  programs.mcp = {
    enable = true;

    servers = {
      github = {
        type = "http";
        url = "https://api.githubcopilot.com/mcp";
        headers = {
          Authorization = "Bearer \${GITHUB_MCP_TOKEN}";
        };
      };
    };
  };
}
