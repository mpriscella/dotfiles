return {
  Lua = {
    completion = {
      callSnippet = "Replace",
    },
    diagnostics = {
      globals = { "vim" },
    },
    runtime = {
      version = "LuaJIT",
    },
    workspace = {
      library = vim.api.nvim_get_runtime_file("", true),
    },
  },
}
