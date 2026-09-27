# https://github.com/nix-community/home-manager/blob/master/modules/programs/opencode.nix
{
  inputs,
  system,
  ...
}: let
  # opencode tracks nixpkgs-unstable rather than the pinned weekly snapshot,
  # which is still on 1.18.30. That release is compiled with a bun 1.4.2 that
  # mis-splits the bundle, so SystemPrompt.environment dereferences an
  # undefined node and *every* prompt dies with "undefined is not an object
  # (evaluating 'a.name')" — surfacing in the TUI as "Failed to send prompt /
  # Unexpected server error". It fails before any provider is contacted, so it
  # looks like a credential problem and isn't one. Fixed upstream in 1.18.31
  # (anomalyco/opencode#48397). Drop this pin once nixpkgs-weekly catches up.
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  programs.opencode = {
    enable = true;
    package = pkgs-unstable.opencode;
    settings = {
      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options = {
            baseURL = "http://127.0.0.1:11434/v1";
          };
          models = {
            "qwen3.6" = {};
          };
        };
      };
    };
  };
}
