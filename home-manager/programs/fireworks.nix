# Route Claude Code and OpenCode through the Fireworks gateway, declaratively.
#
# This is a Nix-native stand-in for FireConnect (https://docs.fireworks.ai/nexus/fireconnect).
# The upstream CLI works by atomically rewriting ~/.claude/settings.json and
# ~/.config/opencode/opencode.json, restoring a backup on `fireconnect <harness>
# off` — which can't work here, since both are read-only symlinks into the Nix
# store written by programs.claude-code and programs.opencode. Rather than fight
# it, this module writes the settings the CLI would, and the `enable` attrset
# below is the on/off switch — one flag per harness, flipped independently.
#
# The API key is deliberately NOT part of either generated config: they land
# world-readable in the Nix store, and this repo is public. Both harnesses read
# it indirectly from the same sops secret — OpenCode by interpolating the
# secret's path at read time, Claude Code via an ANTHROPIC_CUSTOM_HEADERS
# export from fish, since its settings.env can only hold literals.
{
  config,
  lib,
  ...
}: let
  # One flag per harness: flip either to true and rebuild, false restores that
  # harness's stock provider. They're independent, so OpenCode can run on
  # Fireworks while Claude Code stays on Anthropic (useful for trying a router
  # out without putting every Claude Code session behind the gateway). Either
  # one requires the fireworks_api_key secret (see README note).
  enable = {
    claude = false;
    opencode = true;
  };

  # The secret is shared, so it's declared if either harness wants it.
  anyEnabled = enable.claude || enable.opencode;

  # Fireworks' Anthropic-compatible endpoint.
  baseUrl = "https://api.fireworks.ai/inference";

  # Which Fireworks router backs each Claude Code model slot. Other published
  # routers: firerouter (general mix), glm-latest, glm-fast-latest,
  # kimi-fast-latest, deepseek-flash-latest, deepseek-pro-latest. A slot left
  # out falls back to Claude's own default, which the gateway also serves.
  router = name: "accounts/fireworks/routers/${name}";
  models = {
    ANTHROPIC_DEFAULT_OPUS_MODEL = router "firerouter";
    ANTHROPIC_DEFAULT_SONNET_MODEL = router "firerouter";
    ANTHROPIC_DEFAULT_HAIKU_MODEL = router "kimi-fast-latest";
    ANTHROPIC_DEFAULT_FABLE_MODEL = router "kimi-fast-latest";
    CLAUDE_CODE_SUBAGENT_MODEL = router "kimi-fast-latest";
  };

  # OpenCode resolves `fireworks-ai` from models.dev, so the provider needs no
  # npm/baseURL — only a key and metadata for refs models.dev doesn't carry.
  # Routers aren't in that registry, so their context/output limits have to be
  # stated here or OpenCode assumes a generic default.
  opencodeProvider = "fireworks-ai";
  opencodeModels = {
    firerouter = {
      name = "FireRouter";
      limit = {
        context = 1048575;
        output = 131072;
      };
      modalities.input = ["text" "image"];
    };
    auto = {
      name = "Auto";
      limit = {
        context = 1048575;
        output = 131072;
      };
      modalities.input = ["text" "image"];
    };
    # The `-latest` aliases float, so their true limits come from the live
    # serverless catalog that FireConnect caches. These are the conservative
    # fallbacks it uses when that cache is cold; raise them if a model reports
    # more headroom.
    kimi-fast-latest = {
      name = "Kimi Fast (latest)";
      limit = {
        context = 1000000;
        output = 16384;
      };
    };
  };

  # Behavior tuning FireConnect applies alongside the routing. Each of these
  # exists for a reason upstream, so they travel with the routing rather than
  # living in claude-code.nix.
  behavior = {
    # Claude Code disables MCP tool search whenever ANTHROPIC_BASE_URL isn't
    # api.anthropic.com; force it back on so deferred tool loading still works.
    ENABLE_TOOL_SEARCH = "true";
    # The built-in Explore agent caps inherited models at Opus. A Fireworks
    # parent model fails that mapping and lands on Opus, billing every
    # exploration call at Opus rates.
    CLAUDE_CODE_DISABLE_EXPLORE_INHERIT_CAP = "1";
    # The gateway doesn't implement the server-side auto-mode classifier yet;
    # asking for it only earns an ineligibility notice while the local
    # classifier requests get billed anyway.
    CLAUDE_CODE_AUTO_MODE_SERVER = "0";
    CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING = "1";
    # Nix owns the Claude Code install; never let it self-update.
    CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE = "0";
    # Cut Anthropic-bound startup traffic that a gateway session has no use for.
    DISABLE_TELEMETRY = "1";
    DO_NOT_TRACK = "1";
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
  };
in {
  # Declared only when routing is on: sops validates every declared secret at
  # build time, so an unconditional entry would break `nix flake check` for
  # anyone who hasn't added the key to secrets/secrets.yaml yet.
  sops.secrets = lib.mkIf anyEnabled {fireworks_api_key = {};};

  programs.claude-code.settings.env = lib.mkIf enable.claude (behavior
    // models
    // {
      ANTHROPIC_BASE_URL = baseUrl;
      # Deliberately no ANTHROPIC_API_KEY. FireConnect's enable path passes
      # useApiKeySentinel: false, and setting one here makes Claude Code warn
      # that a claude.ai session and an API key are both present. Claude Code
      # keeps its own OAuth login and attaches Anthropic auth at request time;
      # the gateway is authenticated by X-Fireworks-Api-Key alone.
    });

  # OpenCode keeps its own provider block rather than env vars. Merges with the
  # ollama provider declared in opencode.nix.
  programs.opencode.settings = lib.mkIf enable.opencode {
    provider.${opencodeProvider} = {
      # OpenCode interpolates {file:...} when it reads the config, so the key
      # stays out of the store without any indirection of our own. Deliberately
      # not {env:FIREWORKS_API_KEY}: that only resolves in a fish session
      # started after the rebuild, and an unset var interpolates to the empty
      # string, so opencode fails with "You must provide an API key" instead of
      # anything pointing at the shell.
      options.apiKey = "{file:${config.sops.secrets.fireworks_api_key.path}}";
      models = opencodeModels;
    };
    model = "${opencodeProvider}/firerouter";
  };

  # The credential itself, kept out of the Nix store. Mirrors the
  # github_mcp_token pattern in fish.nix.
  programs.fish.interactiveShellInit = lib.optionalString enable.claude ''

    # Fireworks gateway credential (see programs/fireworks.nix). Claude Code
    # only. OpenCode reads the secret file itself, so it needs nothing here.
    if test -r ${config.sops.secrets.fireworks_api_key.path}
      set -gx ANTHROPIC_CUSTOM_HEADERS "X-Fireworks-Api-Key: "(cat ${config.sops.secrets.fireworks_api_key.path})
    end
  '';
}
