local REGISTRY = "https://registry.terraform.io"

-- Terraform Registry API lookups, memoized for the session.
local api_cache = {}

local function registry_api(path)
  if api_cache[path] == nil then
    local out = vim.fn.system({ "curl", "-sfm", "3", REGISTRY .. "/v1" .. path })
    local failed = vim.v.shell_error ~= 0
    local ok, decoded = pcall(vim.json.decode, out)
    api_cache[path] = (not failed and ok) and decoded or false
  end
  return api_cache[path] or nil
end

local function version_key(version)
  local major, minor, patch = version:match("^(%d+)%.(%d+)%.(%d+)$")
  if not major then
    return nil -- unparseable, or a prerelease we would rather not land on
  end
  return tonumber(major) * 1e6 + tonumber(minor) * 1e3 + tonumber(patch)
end

-- Resolve a version pin to a registry path segment. Exact pins are used as-is;
-- a constraint resolves to the newest release sharing its major, which is what
-- someone pinned to `~> 5.0` wants to read. Returns nil to mean `latest`.
-- `fetch` is called only when a constraint actually needs resolving.
local function resolve_version(pin, fetch)
  if not pin then
    return nil
  end

  local exact = pin:match("^%s*=?%s*v?(%d+%.%d+%.%d+)%s*$")
  if exact then
    return exact
  end

  local major = pin:match("(%d+)")
  if not major then
    return nil
  end

  local best, best_key
  for _, release in ipairs(fetch()) do
    local version = release.version
    local key = version_key(version)
    local in_series = version:match("^" .. major .. "%.") ~= nil
    if key and in_series and (not best_key or key > best_key) then
      best, best_key = version, key
    end
  end
  return best
end

local function module_versions(module)
  return function()
    local data = registry_api("/modules/" .. module .. "/versions")
    local entry = data and data.modules and data.modules[1]
    return (entry and entry.versions) or {}
  end
end

local function provider_versions(source)
  return function()
    local data = registry_api("/providers/" .. source .. "/versions")
    return (data and data.versions) or {}
  end
end

-- The `version` pin lives on a sibling line, so look around the cursor for the
-- enclosing block's pin. Assumes canonically formatted HCL: the block header
-- starts at column 0 and the block closes with `}` at column 0.
local function block_version_pin()
  local cursor = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local first = cursor
  while first > 1 and not lines[first]:match("^%S") do
    first = first - 1
  end

  local last = cursor
  while last < #lines and not lines[last]:match("^}") do
    last = last + 1
  end

  for i = first, last do
    local pin = lines[i]:match("^%s*version%s*=%s*\"([^\"]+)\"")
    if pin then
      return pin
    end
  end
end

-- Submodules get renamed and removed between majors, so only link straight to
-- one when the registry confirms it exists at this version -- otherwise fall
-- back to the module page, which carries a submodule picker.
local function submodule_exists(module, version, submodule)
  local path = "/modules/" .. module .. (version and ("/" .. version) or "")
  local data = registry_api(path)
  if not (data and data.submodules) then
    return false
  end

  for _, entry in ipairs(data.submodules) do
    if entry.path and entry.path:gsub("^modules/", "") == submodule then
      return true
    end
  end
  return false
end

-- Provider requirements are per-directory and usually live in versions.tf
-- rather than the file under the cursor, so gather the whole module. The
-- current buffer is read unsaved so a just-added block still counts.
local function module_tf_text()
  local current = vim.api.nvim_buf_get_name(0)
  local chunks = { table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n") }

  local dir = vim.fn.fnamemodify(current, ":h")
  local ok, entries = pcall(vim.fs.dir, dir)
  if ok then
    for name, kind in entries do
      local path = dir .. "/" .. name
      if kind == "file" and name:match("%.tf$") and path ~= current then
        local read, lines = pcall(vim.fn.readfile, path)
        if read then
          chunks[#chunks + 1] = table.concat(lines, "\n")
        end
      end
    end
  end

  return table.concat(chunks, "\n")
end

-- Slice out each `required_providers { ... }` body by balancing braces --
-- a non-greedy pattern would stop at the first nested provider entry's `}`.
local function required_providers_bodies(text)
  local bodies = {}
  local from = 1

  while true do
    local open_start, open_end = text:find("required_providers%s*{", from)
    if not open_start then
      return bodies
    end

    local depth, i = 1, open_end + 1
    while i <= #text and depth > 0 do
      local char = text:sub(i, i)
      if char == "{" then
        depth = depth + 1
      elseif char == "}" then
        depth = depth - 1
      end
      i = i + 1
    end

    bodies[#bodies + 1] = text:sub(open_end + 1, i - 2)
    from = i
  end
end

-- Find the `required_providers` entry for a provider local name, returning its
-- source address and version pin (either may be absent).
local function provider_requirement(local_name)
  local key = local_name:gsub("(%W)", "%%%1") -- literal, not a pattern

  for _, body in ipairs(required_providers_bodies(module_tf_text())) do
    local entry = body:match(key .. "%s*=%s*{(.-)}")
    if entry then
      return entry:match("source%s*=%s*\"([^\"]+)\""),
        entry:match("version%s*=%s*\"([^\"]+)\"")
    end

    -- Legacy shorthand: `helm = "~> 2.0"`, a version with no source.
    local shorthand = body:match(key .. "%s*=%s*\"([^\"]+)\"")
    if shorthand then
      return nil, shorthand
    end
  end
end

-- Strip the public registry host; return nil for a private registry, whose
-- URLs are host-specific rather than registry.terraform.io shaped.
local function public_address(addr)
  addr = addr:gsub("^registry%.terraform%.io/", "")
  if addr:match("^[^/]+%.[^/]+/") then
    return nil
  end
  return addr
end

-- Docs for a `resource`/`data` block. Terraform reads the type's first
-- underscore-separated word as a provider local name, so that word selects the
-- `required_providers` entry and the rest is the docs slug. Unlisted providers
-- default to the hashicorp namespace, exactly as Terraform itself does.
local function block_docs_url(kind, type_name)
  local local_name, slug = type_name:match("^([^_]+)_(.+)$")
  if not local_name then
    local_name, slug = type_name, type_name
  end

  -- Not registry providers: these two ship inside Terraform itself.
  local core_docs = "https://developer.hashicorp.com/terraform/language"
  if type_name == "terraform_data" then
    return core_docs .. "/resources/terraform-data"
  elseif type_name == "terraform_remote_state" then
    return core_docs .. "/state/remote-state-data"
  end

  local source, pin = provider_requirement(local_name)
  source = public_address(source or ("hashicorp/" .. local_name))
  if not source then
    return
  end

  -- A bare `source = "helm"` means the default namespace.
  if not source:match("/") then
    source = "hashicorp/" .. source
  end

  local version = resolve_version(pin, provider_versions(source)) or "latest"
  local category = (kind == "data") and "data-sources" or "resources"

  return REGISTRY
    .. "/providers/"
    .. source
    .. "/"
    .. version
    .. "/docs/"
    .. category
    .. "/"
    .. slug
end

-- Docs for a `source = "..."` argument: the registry page for a registry
-- module (submodules included), or the repo for a git source.
local function source_docs_url(source)
  -- A local path has no docs page.
  if source:match("^%.") or source:match("^/") then
    return
  end

  -- Git sources: open the repo, dropping the git:: prefix, scheme, user@,
  -- //subdir and ?ref=.
  local git = source:match("^git::(.*)$")
    or source:match("^(git@.*)$")
    or source:match("^(github%.com/.*)$")
  if git then
    local repo = git
      :gsub("^%w+://", "")
      :gsub("^[^@/]+@", "")
      :gsub(":", "/", 1)
      :gsub("//.*$", "")
      :gsub("%?.*$", "")
      :gsub("%.git$", "")
    return "https://" .. repo
  end

  local addr = public_address(source)
  if not addr then
    return
  end

  -- Registry modules: namespace/name/provider[//modules/submodule].
  local module, submodule = addr:match("^([^/]+/[^/]+/[^/]+)//(.+)$")
  module = module or addr:match("^[^/]+/[^/]+/[^/]+$")
  if module then
    local version = resolve_version(block_version_pin(), module_versions(module))
    local url = REGISTRY .. "/modules/" .. module .. "/" .. (version or "latest")

    submodule = submodule and submodule:gsub("^modules/", "")
    if submodule and submodule_exists(module, version, submodule) then
      url = url .. "/submodules/" .. submodule
    end
    return url
  end

  -- Two segments is a provider source inside `required_providers`.
  if addr:match("^[^/]+/[^/]+$") then
    local version = resolve_version(block_version_pin(), provider_versions(addr))
    return REGISTRY
      .. "/providers/"
      .. addr
      .. "/"
      .. (version or "latest")
      .. "/docs"
  end
end

-- A local `source` has no docs page, but it does have a file on disk. gx.nvim
-- handlers can only return a URL for the browser to open, so jumping to the
-- module happens at the keymap instead -- before `:Browse` is consulted.
-- Returns the file to edit, or nil to let gx handle the line as usual.
local function local_source_target()
  -- Normal mode only: a visual selection is gx's to interpret.
  if vim.fn.mode() ~= "n" or not vim.tbl_contains({ "terraform", "hcl" }, vim.bo.filetype) then
    return
  end

  local source = require("gx.helper").find(
    vim.api.nvim_get_current_line(),
    "n",
    '%f[%w]source%s*=%s*"([^"]+)"'
  )
  if not source or not (source:match("^%.") or source:match("^/")) then
    return
  end

  local path = source
  if source:match("^%.") then
    path = vim.fs.normalize(vim.fn.expand("%:p:h") .. "/" .. source)
  end

  if vim.fn.isdirectory(path) == 0 then
    return vim.fn.filereadable(path) == 1 and path or nil
  end

  -- Land on the module's entry point rather than a directory listing.
  for _, name in ipairs({ "main.tf", "variables.tf" }) do
    if vim.fn.filereadable(path .. "/" .. name) == 1 then
      return path .. "/" .. name
    end
  end

  local tf = vim.fn.glob(path .. "/*.tf", false, true)
  return tf[1] or path
end

return {
  "chrishrb/gx.nvim",
  keys = {
    {
      "gx",
      function()
        local target = local_source_target()
        if target then
          vim.cmd.edit(vim.fn.fnameescape(target))
        else
          vim.cmd.Browse()
        end
      end,
      mode = { "n", "x" },
      desc = "Open link, docs, or local module under cursor",
    },
  },
  cmd = { "Browse" },
  init = function()
    -- Disable netrw's built-in gx so gx.nvim owns the mapping.
    vim.g.netrw_nogx = 1
  end,
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("gx").setup({
      handlers = {
        -- Named `terraform` deliberately: this replaces gx.nvim's builtin
        -- handler of the same name, which only knows four hardcoded provider
        -- prefixes, always assumes the hashicorp namespace, and ignores
        -- `source` arguments entirely.
        terraform = {
          name = "terraform",
          filetype = { "terraform", "hcl" },
          handle = function(mode, line, _)
            local helper = require("gx.helper")

            local source = helper.find(line, mode, '%f[%w]source%s*=%s*"([^"]+)"')
            if source then
              return source_docs_url(source)
            end

            -- Span the type *and* name strings so the cursor can sit anywhere
            -- on the block header.
            local header = '%s+"([^"]+)"%s+"[^"]*"'
            local type_name = helper.find(line, mode, "%f[%w]resource" .. header)
            if type_name then
              return block_docs_url("resource", type_name)
            end

            type_name = helper.find(line, mode, "%f[%w]data" .. header)
            if type_name then
              return block_docs_url("data", type_name)
            end
          end,
        },

        -- Open the repo for a workflow `uses:` action ref. Captures the first
        -- two path segments (owner/repo), ignoring any /subpath and @ref.
        -- Scoped to YAML so it can't misfire elsewhere.
        github_actions = {
          name = "github_actions",
          filetype = { "yaml" },
          handle = function(mode, line, _)
            local repo = require("gx.helper").find(
              line,
              mode,
              "uses:%s*([%w][%w%._-]*/[%w%._-]+)"
            )
            if repo then
              return "https://github.com/" .. repo
            end
          end,
        },
      },
    })
  end,
}
