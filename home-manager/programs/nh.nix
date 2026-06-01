# https://github.com/nix-community/home-manager/blob/master/modules/programs/nh.nix
{config, ...}: {
  programs.nh = {
    enable = true;

    # Sets NH_FLAKE so `nh darwin switch -H <hostname>` works from any
    # directory without a path argument.
    flake = "${config.home.homeDirectory}/workspace/mpriscella/dotfiles";
  };
}
