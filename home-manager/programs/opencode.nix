# https://github.com/nix-community/home-manager/blob/master/modules/programs/opencode.nix
{...}: {
  programs.opencode = {
    enable = true;
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
