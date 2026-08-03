{pkgs, ...}: let
  # act resolves its XDG config dir via the adrg/xdg Go library, which on
  # macOS uses ~/Library/Application Support (NOT ~/.config). Write actrc to
  # the platform's actual read path so it's picked up.
  actConfigDir =
    if pkgs.stdenv.isDarwin
    then "Library/Application Support/act"
    else ".config/act";
in {
  home.packages = [pkgs.act];

  home.file."${actConfigDir}/actrc".text = ''
    --container-architecture linux/amd64
    -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
    -P ubuntu-24.04=ghcr.io/catthehacker/ubuntu:act-24.04
    -P ubuntu-22.04=ghcr.io/catthehacker/ubuntu:act-22.04
    --action-offline-mode
    --log-prefix-job-id
    --pull=false
    --reuse
  '';
}
