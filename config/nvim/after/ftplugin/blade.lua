-- Blade is not a builtin filetype, so there is no $VIMRUNTIME/ftplugin/blade
-- to override these. Kept in after/ftplugin for parity with php.lua.

-- 4-space indentation, matching blade-formatter's default indent_size (the
-- global default is 2).
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

-- Blade comment syntax for gcc/comment-toggling.
vim.opt_local.commentstring = "{{-- %s --}}"
