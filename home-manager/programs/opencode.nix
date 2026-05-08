# https://github.com/nix-community/home-manager/blob/master/modules/programs/opencode.nix
{...}: {
  programs.opencode = {
    enable = true;
    settings = {
      provider = {
        lmstudio = {
          npm = "@ai-sdk/openai-compatible";
          name = "LM Studio";
          options = {
            baseURL = "http://127.0.0.1:1234/v1";
          };
          models = {
            "qwen3.6-35b-a3b-nvfp4" = {
              name = "Qwen 3.6";
            };
          };
        };
      };
    };
  };
}
