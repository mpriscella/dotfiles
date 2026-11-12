-- Long-running event handlers for every Rex session. The rex-watch launchd
-- agent (home-manager/programs/rex.nix) runs it as
--   rex do --all watch.lua
-- Run it the same way by hand to try a change; Ctrl-C to stop. Logs go to
-- ~/Library/Logs/rex-watch.log under launchd.
--
--   1. Labels shell panes with their directory ("ai-toolbox/").
--   2. Sends a macOS notification when a pane's program exits with an error.
--   3. Saves each session's layout for the restore_layout action (actions.lua).

local TERMINAL = "com.superlogical.terminal"
local SHELL = "com.superlogical.terminal.shell"
local HOME = os.getenv("HOME")

-- Must match LAYOUT_DIR and snapshot_path in actions.lua.
local LAYOUT_DIR = HOME .. "/.local/state/rex/layouts"

local function snapshot_path(session_label)
  return LAYOUT_DIR .. "/" .. session_label:gsub("[^%w._-]", "_") .. ".json"
end

-- Terminals report their directory as a percent-encoded file:// URL.
local function url_path(url)
  local path = url:gsub("^file://[^/]*", "")
  return (path:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

-- Shells report their directory; a pane running a plain command may not, so
-- fall back to its process's.
local function block_cwd(session_id, block_id)
  local args = { session_id = session_id, block_id = block_id }
  local r = rex.block.call(TERMINAL, "pwd", args)
  if r and r.pwd and r.pwd ~= "" then return url_path(r.pwd) end
  local p = rex.block.call(TERMINAL, "process", args)
  local proc = p and (p.foreground or p.child)
  return proc and proc.cwd
end

local function find_block(session_id, block_id)
  local r = rex.session.list_blocks{ session_id = session_id }
  for _, b in ipairs(r and r.blocks or {}) do
    if b.block_id == block_id then return b end
  end
end

local function notify(title, text)
  rex.exec({
    "osascript",
    "-e", "on run argv",
    "-e", "display notification (item 2 of argv) with title (item 1 of argv)",
    "-e", "end run",
    title, text,
  }, { timeout = 5 })
end

-- 3. Layout snapshots --------------------------------------------------------

-- Turn a view layout node into the layout table new_window takes. Panes come
-- back as plain shells in the same directory with the same label; whatever
-- ran in them is not restarted.
local function to_layout(session_id, node, labels)
  if node.split then
    local before = to_layout(session_id, node.split.before, labels)
    local after = to_layout(session_id, node.split.after, labels)
    if not before or not after then return before or after end
    return { split = {
      direction = node.split.direction,
      ratio     = node.split.ratio,
      before    = before,
      after     = after,
    } }
  end
  if node.block_id then
    return { block = {
      flavor  = SHELL,
      label   = labels[node.block_id],
      options = { cwd = block_cwd(session_id, node.block_id) },
    } }
  end
end

local function snapshot(session_id)
  local view = rex.session.view{ session_id = session_id }
  -- A session being torn down has no windows; keep its last good snapshot.
  if not view or not view.label or #(view.windows or {}) == 0 then return end

  local windows = {}
  for _, w in ipairs(view.windows) do
    for _, layer in ipairs(w.layers or {}) do
      if layer.kind == "tiled" and layer.layout then
        local labels = {}
        for _, b in ipairs(layer.blocks or {}) do labels[b.block_id] = b.label end
        local layout = to_layout(session_id, layer.layout, labels)
        if layout then
          -- Skip Rex's generated "Window 1a2b3c4d" names.
          local label = w.label
          if label and label:match("^Window %x+$") then label = nil end
          windows[#windows + 1] = { label = label, layout = layout }
        end
      end
    end
  end
  if #windows == 0 then return end

  local text = rex.json.encode({
    session  = view.label,
    saved_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    windows  = windows,
  }, { indent = true })
  local path = snapshot_path(view.label)
  local f = io.open(path .. ".tmp", "w")
  if not f then return end
  f:write(text)
  f:close()
  os.rename(path .. ".tmp", path)
end

-- Layout changes arrive in bursts; save once things settle.
local pending = {}
local function schedule_snapshot(session_id)
  if pending[session_id] then pending[session_id]:cancel() end
  pending[session_id] = rex.after(2, function()
    pending[session_id] = nil
    snapshot(session_id)
  end)
end

rex.exec({ "mkdir", "-p", LAYOUT_DIR })

rex.on("session_view_changed", function(ctx, ev)
  schedule_snapshot(ctx.session_id)
end)

-- 1. Directory labels --------------------------------------------------------

-- Only relabel panes still on the default "shell" label or on one this
-- script set (it ends in "/"), so labels that people and skills choose stay.
local function auto_labeled(label)
  return label == nil or label == "" or label == "shell" or label:sub(-1) == "/"
end

rex.on("terminal.pwd_changed", function(ctx, ev)
  schedule_snapshot(ctx.session_id)

  local b = find_block(ctx.session_id, ctx.block_id)
  if not b or not auto_labeled(b.label) then return end
  local path = url_path(ev.pwd)
  local name = path == HOME and "~" or path:match("([^/]+)/?$") or "/"
  if name .. "/" ~= b.label then
    rex.session.set_block_label{ block_id = ctx.block_id, label = name .. "/" }
  end
end)

-- 2. Crash notifications -----------------------------------------------------

-- Ctrl-C (130), SIGTERM (143), and signal deaths (-1) are someone stopping
-- the program on purpose, not a crash.
local QUIET_EXITS = { [0] = true, [130] = true, [143] = true, [-1] = true }
local last_notified = {}

rex.on("terminal.child_exited", function(ctx, ev)
  if QUIET_EXITS[ev.exit_code] then return end
  local now = os.time()
  if last_notified[ctx.block_id] and now - last_notified[ctx.block_id] < 30 then return end
  last_notified[ctx.block_id] = now

  local view = rex.session.view{}
  local b = find_block(ctx.session_id, ctx.block_id)
  notify(
    "Rex: " .. ((view and view.label) or "session"),
    string.format("%s exited %d", (b and b.label) or "A pane", ev.exit_code))
end)
