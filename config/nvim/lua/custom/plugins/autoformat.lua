return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Escape hatch for files where the formatter fights the content
      -- (e.g. prettier vs Slidev slide separators — see docs/slidev.md).
      -- Toggled by :FormatDisable[!] / :FormatEnable below.
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end

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
        -- Pint itself formats a file in ~200ms, but format_on_save runs
        -- synchronously and blocks the write, so a *cold* invocation — PHP +
        -- Composer autoloader warmup, plus macOS Gatekeeper's first-run
        -- assessment of the Nix-store php binary — or CPU contention at save
        -- time can spike well past a shorter ceiling. 3000ms still timed out
        -- intermittently in practice; 8000ms absorbs those spikes (a genuinely
        -- stuck run is not a failure mode pint exhibits). notify_on_error =
        -- false means a timeout would otherwise silently leave the file
        -- unformatted.
        timeout_ms = vim.bo[bufnr].filetype == "php" and 8000 or 500,
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
  config = function(_, opts)
    require("conform").setup(opts)

    -- :FormatDisable turns format-on-save off globally, :FormatDisable!
    -- only for the current buffer; :FormatEnable undoes both.
    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, { desc = "Disable format-on-save (! = buffer only)", bang = true })
    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, { desc = "Re-enable format-on-save" })
  end,
}
