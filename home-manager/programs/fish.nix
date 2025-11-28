{...}: {
  programs.fish = {
    enable = true;

    shellAliases = {
      cat = "bat";
      lg = "lazygit";
    };

    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings
    '';
  };

  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];
}
