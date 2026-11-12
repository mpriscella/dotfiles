# Rex (https://www.superlogical.com/rex): config, the rex-status helper, and
# the event watcher. Rex itself is the Rex Beta app (not in nixpkgs); fish.nix
# puts its CLI on PATH.
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Launchd and activation scripts don't get fish's PATH, so call the CLI
  # inside the app bundle directly.
  rexBin = "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex";

  # Reports a program's state to the terminal with the Program Status Protocol
  # (OSC 7501): Rex shows it as tab spinners and session-picker indicators, and
  # scripts can wait on it. Writes only when stdout is a terminal, so it is a
  # no-op in pipes, in CI, and from Claude Code's Bash tool (which would
  # otherwise clobber Claude's own status record).
  rex-status = pkgs.writeShellApplication {
    name = "rex-status";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      usage() {
        cat <<'EOF'
      Usage:
        rex-status STATE [MESSAGE] [--app APP] [--id ID] [--title TITLE] [--progress N]
        rex-status run [--app APP] [--msg MESSAGE] -- COMMAND [ARGS...]

      STATE is idle, working, done, blocked, error, or clear. `run` reports
      working, runs COMMAND, then reports done or error with its exit status
      (idle if interrupted) and exits with that status.
      EOF
      }

      b64() { printf '%s' "$1" | base64 | tr -d '\n'; }

      report() { # report STATE MSG APP ID TITLE PROGRESS
        [ -t 1 ] || return 0
        local body="state=$1"
        [ -n "$2" ] && body="$body:msg=$(b64 "$2")"
        [ -n "$3" ] && body="$body:app=$3"
        [ -n "$4" ] && body="$body:id=$4"
        [ -n "$5" ] && body="$body:title=$(b64 "$5")"
        [ -n "$6" ] && body="$body:progress=$6"
        printf '\033]7501;%s\007' "$body"
      }

      [ $# -ge 1 ] || { usage >&2; exit 2; }
      case "$1" in -h|--help) usage; exit 0 ;; esac

      if [ "$1" = run ]; then
        shift
        app="" msg=""
        while [ $# -gt 0 ] && [ "$1" != -- ]; do
          case "$1" in
            --app) app="$2"; shift 2 ;;
            --msg) msg="$2"; shift 2 ;;
            *) usage >&2; exit 2 ;;
          esac
        done
        [ "''${1:-}" = -- ] && shift
        [ $# -ge 1 ] || { usage >&2; exit 2; }
        [ -n "$msg" ] || msg="$*"
        [ -n "$app" ] || app="$(basename "$1")"

        report working "$msg" "$app" "" "" ""
        status=0
        "$@" || status=$?
        case "$status" in
          0) report "done" "$msg" "$app" "" "" "" ;;
          130) report idle "$msg (interrupted)" "$app" "" "" "" ;;
          *) report error "$msg (exit $status)" "$app" "" "" "" ;;
        esac
        exit "$status"
      fi

      state="$1"; shift
      msg="" app="" id="" title="" progress=""
      if [ $# -gt 0 ] && [ "''${1#--}" = "$1" ]; then msg="$1"; shift; fi
      while [ $# -gt 0 ]; do
        case "$1" in
          --app) app="$2"; shift 2 ;;
          --id) id="$2"; shift 2 ;;
          --title) title="$2"; shift 2 ;;
          --progress) progress="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) usage >&2; exit 2 ;;
        esac
      done
      report "$state" "$msg" "$app" "$id" "$title" "$progress"
    '';
  };
in {
  config = lib.mkMerge [
    {
      home.packages = [rex-status];

      # Linked file by file (not the whole directory) so ~/.config/rex stays
      # writable in case Rex keeps anything of its own there.
      home.file.".config/rex" = {
        source = ../../config/rex;
        recursive = true;
      };
    }

    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      # Rex doesn't watch init.lua. Reloading fails harmlessly (exit 4) when
      # the app isn't running; it reads the file on its next start.
      home.activation.rexConfigReload = lib.hm.dag.entryAfter ["linkGeneration"] ''
        if [ -x "${rexBin}" ]; then
          "${rexBin}" config reload >/dev/null 2>&1 \
            || echo "rex: config not reloaded (Rex not running, or init.lua has errors: run 'rex config check')"
        fi
      '';

      # scripts/watch.lua: directory labels, crash notifications, and layout
      # snapshots for every session. The script is referenced by its store
      # path so a change to it changes the plist and restarts the agent.
      # Exits when the Rex server isn't running; launchd retries.
      launchd.agents.rex-watch = {
        enable = true;
        config = {
          ProgramArguments = [rexBin "do" "--all" "${../../config/rex/scripts/watch.lua}"];
          RunAtLoad = true;
          KeepAlive = true;
          ThrottleInterval = 30;
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/rex-watch.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/rex-watch.log";
        };
      };
    })
  ];
}
