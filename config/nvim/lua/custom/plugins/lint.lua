return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			markdown = { "markdownlint" },
			php = { "mago_lint" },
		}

		-- `mago guard` (architectural/layer rules) has no builtin nvim-lint
		-- definition; it shares mago_lint's short reporting format.
		lint.linters.mago_guard = {
			name = "mago_guard",
			cmd = "mago",
			args = { "--colors=never", "guard", "--reporting-format=short" },
			append_fname = true,
			stdin = false,
			ignore_exitcode = true,
			parser = require("lint.parser").from_pattern(
				"[^:]+:(%d+):(%d+):%s?(%l+)%[([%w-]+)%]:%s?(.+)",
				{ "lnum", "col", "severity", "code", "message" },
				{
					error = vim.diagnostic.severity.ERROR,
					warning = vim.diagnostic.severity.WARN,
					note = vim.diagnostic.severity.INFO,
					help = vim.diagnostic.severity.HINT,
				},
				{ source = "mago_guard" }
			),
		}

		-- Create autocommand which carries out the actual linting
		-- on the specified events.
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function(args)
				lint.try_lint()

				-- Guard rules are project-level config; only run where the
				-- project defines a mago.toml.
				if vim.bo[args.buf].filetype == "php" and vim.fs.root(args.buf, "mago.toml") then
					lint.try_lint("mago_guard")
				end
			end,
		})
	end,
}
