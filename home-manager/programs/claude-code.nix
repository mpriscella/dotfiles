# https://github.com/nix-community/home-manager/blob/master/modules/programs/claude-code.nix
{...}: {
  programs.claude-code = {
    enable = true;

    enableMcpIntegration = true;

    agents = {
      notes--daily-summary = ./../../agents/notes/daily-summary.md;
      image--svg-to-png = ./../../agents/image/svg-to-png.md;
    };

    settings = {
      permissions = {
        allow = [
          "Edit(~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Obsidian/Daily Notes/**)"
        ];
        additionalDirectories = ["~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents"];
      };
    };
  };
}
