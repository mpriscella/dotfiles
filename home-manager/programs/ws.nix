# ws: one jj workspace + Rex session per change. The script lives in the
# toolbox plugin (mpriscella/ai-toolbox, skills/ws/scripts/ws); this module
# gives it a `ws` fish function and a launchd agent that runs `ws sweep`
# every 10 minutes, removing workspaces whose PR merged.
#
# Both run the script from the ai-toolbox checkout, not the plugin cache
# (whose path changes with every version), so they run whatever is checked
# out there.
{
  config,
  pkgs,
  ...
}: let
  script = "${config.home.homeDirectory}/workspace/mpriscella/ai-toolbox/plugins/toolbox/skills/ws/scripts/ws";

  # launchd doesn't get fish's PATH, so call the CLI inside whichever Rex app
  # bundle is installed (same as rex.nix).
  rex = pkgs.writeShellScriptBin "rex" ''
    for app in "Rex" "Rex Beta"; do
      bin="/Applications/$app.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
      [ -x "$bin" ] && exec "$bin" "$@"
    done
    echo "rex: neither Rex.app nor Rex Beta.app is installed in /Applications" >&2
    exit 127
  '';

  ws-sweep = pkgs.writeShellApplication {
    name = "ws-sweep";
    runtimeInputs = [pkgs.python3 pkgs.jujutsu pkgs.git pkgs.gh pkgs.gnupg rex];
    text = ''
      [ -f "${script}" ] || { echo "ws: ${script} not found"; exit 0; }
      exec python3 "${script}" sweep
    '';
  };
in {
  programs.fish.functions.ws = {
    description = "One jj workspace + Rex session per change (toolbox ws)";
    body = ''${pkgs.python3}/bin/python3 "${script}" $argv'';
  };

  launchd.agents.ws-sweep = {
    enable = true;
    config = {
      ProgramArguments = ["${ws-sweep}/bin/ws-sweep"];
      StartInterval = 600;
      RunAtLoad = false;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/ws-sweep.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/ws-sweep.log";
    };
  };
}
