{
  config,
  lib,
  system,
  ...
}: let
  isDarwin = lib.hasInfix "darwin" system;
  ageKeyFile =
    if isDarwin
    then "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt"
    else "${config.home.homeDirectory}/.config/sops/age/keys.txt";
in {
  sops = {
    age.keyFile = ageKeyFile;

    defaultSopsFile = ../../secrets/secrets.yaml;

    # macOS launchd service needs PATH for getconf, newfs_hfs, etc.
    environment = lib.mkIf isDarwin {
      PATH = lib.mkForce "/usr/bin:/bin:/usr/sbin:/sbin";
    };

    secrets = {
      github_mcp_token = {};

      my_voice_skill = {
        format = "binary";
        sopsFile = ../../secrets/my-voice/SKILL.md;
        path = "${config.home.homeDirectory}/.claude/skills/my-voice/SKILL.md";
      };
      my_voice_samples = {
        format = "binary";
        sopsFile = ../../secrets/my-voice/voice-samples.md;
        path = "${config.home.homeDirectory}/.claude/skills/my-voice/references/voice-samples.md";
      };
    };
  };
}
