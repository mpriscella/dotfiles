{...}: {
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    keyMode = "vi";
    mouse = true;
    escapeTime = 0;
    terminal = "tmux-256color";
  };
}
