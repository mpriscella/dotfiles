# https://github.com/nix-community/home-manager/blob/master/modules/programs/claude-code.nix
{...}: {
  programs.claude-code = {
    enable = true;

    enableMcpIntegration = true;

    agentsDir = ./../../agents;
    skills = ./../../skills;

    context = ''
      # Version Control

      I prefer jujutsu (`jj`) over the git CLI. Use `jj` commands for version
      control operations (status, diff, describe, commit, log, etc.) rather than
      `git`.

      # Environment Management

      My environment is managed declaratively with Nix (nix-darwin +
      home-manager) from ~/workspace/mpriscella/dotfiles. Do NOT install
      packages imperatively (brew install, npm install -g, pip install, etc.)
      or edit generated config files directly — many are read-only symlinks
      into the Nix store (e.g. ~/.claude/settings.json, ~/.config/**). Instead,
      modify the relevant Nix module in the dotfiles repo and rebuild with
      `nh darwin switch -h <host>`.

      # Shell

      My shell is fish, not bash. Use fish-compatible syntax for any commands
      you ask me to run interactively (e.g. `set -x FOO bar`, not
      `export FOO=bar`).

      # Working Style

      - Be concise. Minimal preamble; get to the point.
      - Still show your reasoning and trade-offs before acting on non-trivial
        work — concise doesn't mean skipping the "why".
      - Ask before making large or hard-to-reverse changes.
    '';

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
