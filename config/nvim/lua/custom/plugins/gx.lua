return {
  "chrishrb/gx.nvim",
  keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
  cmd = { "Browse" },
  init = function()
    -- Disable netrw's built-in gx so gx.nvim owns the mapping.
    vim.g.netrw_nogx = 1
  end,
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("gx").setup({
      handlers = {
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
