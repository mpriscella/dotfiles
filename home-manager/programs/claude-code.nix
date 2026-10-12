# https://github.com/nix-community/home-manager/blob/master/modules/programs/claude-code.nix
{...}: {
  # The executable comes from the native installer
  # (curl -fsSL https://claude.ai/install.sh | bash), which installs to
  # ~/.local/bin and auto-updates. Nix only manages config; skills and agents
  # come from the toolbox plugin in the private mpriscella/ai-toolbox
  # marketplace.
  home.sessionPath = ["$HOME/.local/bin"];

  programs.claude-code = {
    enable = true;
    package = null;

    enableMcpIntegration = true;

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
      into the Nix store (e.g. ~/.config/**). Instead,
      modify the relevant Nix module in the dotfiles repo and rebuild with
      `nh darwin switch -H <host>`.

      The one exception is the Claude Code executable itself: it comes from
      the native installer and auto-updates in ~/.local/bin. This CLAUDE.md
      is still managed by Nix, but ~/.claude/settings.json is NOT: Claude
      Code owns it, so edit it directly. My skills and agents are NOT in
      dotfiles either: they're the `toolbox` plugin in the private
      mpriscella/ai-toolbox marketplace, checked out at
      ~/workspace/mpriscella/ai-toolbox.

      # Shell

      My shell is fish, not bash. Use fish-compatible syntax for any commands
      you ask me to run interactively (e.g. `set -x FOO bar`, not
      `export FOO=bar`).

      # Working Style

      - Be concise. Minimal preamble; get to the point.
      - Still show your reasoning and trade-offs before acting on non-trivial
        work — concise doesn't mean skipping the "why".
      - Ask before making large or hard-to-reverse changes.
      - When spawning `general-purpose` or `Explore` subagents for search,
        lookup, or summarization, pass `model: "sonnet"`; keep the default
        only for work that needs deep reasoning.
    '';
  };
}
