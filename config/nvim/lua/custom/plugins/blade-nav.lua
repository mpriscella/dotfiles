-- Blade component navigation + completion.
--
-- laravel-ls (see lsp.lua) handles route/view/config/env resources but its
-- v0.1.0 lists every Blade-*component* feature as unimplemented, so it can't
-- complete or navigate `<x-...>` tags. blade-nav fills that gap and also does
-- `gf` for PHP-string references (route/view/config/inertia), which is why we
-- no longer run the heavier laravel.nvim:
--   - `gf` jumps from a `<x-dashboard.stat-card>`, `<livewire:*>`, @extends,
--     @include, etc. reference straight to its file (falling back to native
--     `gf` for anything it doesn't recognize).
--   - It exposes a blink.cmp source for `<x-...>` tag completion, registered
--     in autocompletion.lua (no plugin dependency needed for blink).
--
-- `opts` makes lazy.nvim call require('blade-nav').setup(opts), which wires up
-- `gf` on blade/php buffers. We disable the nvim-cmp integration (on by
-- default) since we're on blink — the blink source is registered directly in
-- autocompletion.lua, and leaving cmp enabled just warns "nvim-cmp not found".
return {
  "RicardoRamirezR/blade-nav.nvim",
  ft = { "blade", "php" },
  opts = {
    integrations = {
      cmp = false,
    },
  },
}
