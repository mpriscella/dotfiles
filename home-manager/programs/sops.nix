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

    secrets = {
      github_mcp_token = {};
    };
  };
}
