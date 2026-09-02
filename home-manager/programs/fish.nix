{
  config,
  lib,
  system,
  ...
}: {
  programs.fish = {
    enable = true;

    # cat is always bat, so an alias (the substitution shouldn't be visible).
    shellAliases = {
      cat = "bat";
    };

    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings

      # Load sops secrets as environment variables
      if test -r ${config.sops.secrets.github_mcp_token.path}
        set -gx GITHUB_MCP_TOKEN (cat ${config.sops.secrets.github_mcp_token.path})
      end
    '';

    functions = {
      # Startup greeting: host + timestamp, laptop vitals, plus repo context
      # when the shell opens inside a jj or git checkout. Every line here must
      # stay cheap — this runs on each new tab, split, and `nix develop`.
      fish_greeting = ''
        set_color cyan
        echo -n (prompt_hostname)
        set_color brblack
        echo " · "(date '+%a %b %d · %H:%M')
        set_color normal

        # --- vitals: battery · disk · load -------------------------------
        set -l vitals

        # Battery (macOS only; pmset is absent on the Linux configs).
        if command -q pmset
          set -l batt (pmset -g batt | string match -r '(\d+)%; (\w+)')
          if test (count $batt) -eq 3
            set -l pct $batt[2]
            set -l state $batt[3]
            set -l icon "󰁹"
            test "$state" = charging; and set icon "󰂄"
            set -l color green
            test $pct -le 40; and set color yellow
            test $pct -le 15; and set color red
            set -a vitals (set_color $color)"$icon $pct%"(set_color normal)
          end
        end

        # Free space on the root volume.
        set -l disk (df -h / | tail -1 | string split -n ' ')
        if test (count $disk) -ge 5
          set -l usedpct (string replace -r '%$' "" $disk[5])
          set -l color green
          test $usedpct -ge 85; and set color yellow
          test $usedpct -ge 95; and set color red
          set -a vitals (set_color $color)"󰋊 $disk[4] free"(set_color normal)
        end

        # 1-minute load average.
        set -l load
        if test -r /proc/loadavg
          set load (string split -n ' ' </proc/loadavg)[1]
        else if command -q sysctl
          set load (sysctl -n vm.loadavg | string split -n ' ')[2]
        end
        if test -n "$load"
          set -a vitals (set_color brblack)"󰓅 $load"(set_color normal)
        end

        if test (count $vitals) -gt 0
          set_color brblack
          echo -n "  "
          set_color normal
          echo (string join (set_color brblack)" · "(set_color normal) $vitals)
        end

        # --- repo context -------------------------------------------------
        if test -d .jj
          set -l change (jj log --no-graph --ignore-working-copy -r @ \
            -T 'change_id.short()' 2>/dev/null)
          if test -n "$change"
            set_color brblack
            echo -n "  jj "
            set_color yellow
            echo $change
            set_color normal
          end
        else if test -d .git
          set -l branch (git symbolic-ref --quiet --short HEAD 2>/dev/null)
          if test -n "$branch"
            set_color brblack
            echo -n "  git "
            set_color yellow
            echo $branch
            set_color normal
          end
        end
      '';
    };
  };

  # macOS Homebrew paths, plus the Ghostty app bundle (the CLI lives inside
  # the bundle and is not symlinked onto the PATH at install).
  home.sessionPath = lib.mkIf (lib.hasInfix "darwin" system) [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/Applications/Ghostty.app/Contents/MacOS"
  ];
}
