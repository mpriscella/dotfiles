-- Rex configuration. Linked into ~/.config/rex by home-manager/programs/rex.nix;
-- a rebuild runs `rex config reload`. Iterate on a draft without rebuilding:
--   rex config check config/rex/init.lua
--   rex do config/rex/init.lua --action <name>
--
-- The event watcher (scripts/watch.lua) is not loaded from here: rex.on only
-- works in scripts run with `rex do`, so a launchd agent runs it instead.

require("actions")

-- Personal actions live under a cmd+; prefix (press it, release, then the
-- letter) so they never shadow app keys like cmd+a.
rex.bind("cmd+;>c", "claude_here")
rex.bind("cmd+;>a", "ask_claude")
rex.bind("cmd+;>r", "restore_layout")
rex.bind("cmd+;>e", "claude_engagements")
