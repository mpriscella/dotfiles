return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "V13Axel/neotest-pest",
    "olimorris/neotest-phpunit",
  },
  keys = {
    {
      "<leader>tt",
      function() require("neotest").run.run() end,
      desc = "[T]est nearest",
    },
    {
      "<leader>tf",
      function() require("neotest").run.run(vim.fn.expand("%")) end,
      desc = "[T]est [f]ile",
    },
    {
      "<leader>ts",
      function() require("neotest").summary.toggle() end,
      desc = "[T]est [s]ummary",
    },
    {
      "<leader>to",
      function() require("neotest").output.open({ enter = true }) end,
      desc = "[T]est [o]utput",
    },
  },
  config = function()
    -- setup() deep-merges a partial config over its defaults, but its type
    -- annotation declares every field required.
    ---@diagnostic disable-next-line: missing-fields
    require("neotest").setup({
      adapters = {
        -- Pest first: its detection (vendor/bin/pest) wins in Pest projects,
        -- phpunit covers the rest.
        require("neotest-pest"),
        require("neotest-phpunit"),
      },
    })
  end,
}
