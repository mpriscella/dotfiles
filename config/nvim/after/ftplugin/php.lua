-- Lives in after/ftplugin (not ftplugin/) so these run after
-- $VIMRUNTIME/ftplugin/php.vim, which otherwise overrides commentstring
-- and comments.

-- PSR-12 indentation: 4 spaces (the global default is 2). Matches what
-- mago_format produces on save.
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

-- Comment leaders: a single s1/mb/ex triplet covers both `/*` and `/**`
-- blocks; PHP 8 attributes (`f:#[`) precede `:#` so attribute lines match
-- their own rule rather than the generic # comment.
vim.opt_local.comments = {
  "s1:/*", "mb:*", "ex:*/",
  "://",
  "f:#[",
  ":#",
}

-- Continue the comment leader when hitting <Enter> in insert mode.
vim.opt_local.formatoptions:append("r")

-- Line comments for gcc/comment-toggling (the runtime default is `/* %s */`).
vim.opt_local.commentstring = "// %s"
