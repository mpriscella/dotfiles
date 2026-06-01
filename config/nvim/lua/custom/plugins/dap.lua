return {
  "mfussenegger/nvim-dap",
  dependencies = {
    { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
  },
  keys = {
    {
      "<leader>db",
      function() require("dap").toggle_breakpoint() end,
      desc = "[D]ebug: toggle [b]reakpoint",
    },
    {
      "<leader>dc",
      function() require("dap").continue() end,
      desc = "[D]ebug: [c]ontinue / start",
    },
    {
      "<leader>di",
      function() require("dap").step_into() end,
      desc = "[D]ebug: step [i]nto",
    },
    {
      "<leader>do",
      function() require("dap").step_over() end,
      desc = "[D]ebug: step [o]ver",
    },
    {
      "<leader>dO",
      function() require("dap").step_out() end,
      desc = "[D]ebug: step [O]ut",
    },
    {
      "<leader>du",
      function() require("dapui").toggle() end,
      desc = "[D]ebug: toggle [u]i",
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    -- php-debug-adapter is a home-manager wrapper around vscode-php-debug
    -- (see home.nix). Guest Xdebug connects back on the standard port 9003.
    dap.adapters.php = {
      type = "executable",
      command = "php-debug-adapter",
    }
    dap.configurations.php = {
      {
        type = "php",
        request = "launch",
        name = "Listen for Xdebug",
        port = 9003,
      },
    }
  end,
}
