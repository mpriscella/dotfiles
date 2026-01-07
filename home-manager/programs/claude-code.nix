# https://github.com/nix-community/home-manager/blob/master/modules/programs/claude-code.nix
{...}: {
  programs.claude-code = {
    enable = true;

    mcpServers = {
      github = {
        type = "http";
        url = "https://api.githubcopilot.com/mcp/";
        headers = {
          Authorization = "Bearer \${GITHUB_MCP_TOKEN}";
        };
      };
    };
  };
}
