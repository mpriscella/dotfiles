return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { cpp = true }
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = "never"
      else
        lsp_format_opt = "fallback"
      end
      return {
        timeout_ms = 500,
        lsp_format = lsp_format_opt,
      }
    end,
    formatters_by_ft = {
      blade = { "blade-formatter" },
      css = { "prettierd" },
      html = { "prettierd" },
      javascript = { "prettierd" },
      javascriptreact = { "prettierd" },
      json = { "prettierd" },
      jsonc = { "prettierd" },
      lua = { "lua-language-server" },
      markdown = { "prettierd" },
      nix = { "alejandra" },
      -- Pint and Mago disagree structurally (Mago re-prints chains,
      -- ternaries, and argument lists; Pint preserves layout), so projects
      -- that ship Pint format with it to avoid drift from the repo style.
      php = function(bufnr)
        local root = vim.fs.root(bufnr, "composer.json")
        if root and vim.uv.fs_stat(root .. "/vendor/bin/pint") then
          return { "pint" }
        end
        return { "mago_format" }
      end,
      scss = { "prettierd" },
      typescript = { "prettierd" },
      typescriptreact = { "prettierd" },
      vue = { "prettierd" },
      yaml = { "prettierd" },
    },
  },
}
