return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI for debugging
      "rcarriga/nvim-dap-ui",
      -- Go debug adapter
      "leoluz/nvim-dap-go",
      -- Virtual text for debugging
      "theHamsta/nvim-dap-virtual-text",
      -- Mason integration for DAP
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      
      -- Setup Go debugging
      require("dap-go").setup({
        delve = {
          path = "dlv",
          initialize_timeout_sec = 20,
          port = "${port}",
          args = {},
          build_flags = "",
        },
        -- Configure default test options
        dap_configurations = {
          {
            type = "go",
            name = "Debug Package",
            request = "launch",
            program = "${fileDirname}",
          },
          {
            type = "go",
            name = "Debug Test",
            request = "launch",
            mode = "test",
            program = "${file}",
          },
          {
            type = "go",
            name = "Debug Test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}",
          },
        },
      })
      
      -- Enable virtual text
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        virt_text_pos = 'eol',
      })
      
      -- Configure the UI
      dapui.setup({
        icons = { expanded = "", collapsed = "", current_frame = "" },
        mappings = {
          -- Use a table to apply multiple mappings
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 10,
            position = "bottom",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
        },
      })
      
      -- Auto open and close the UI when debugging
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
      
      -- Set up icons
      vim.fn.sign_define('DapBreakpoint', { text='', texthl='DiagnosticSignError', linehl='', numhl='' })
      vim.fn.sign_define('DapBreakpointCondition', { text='', texthl='DiagnosticSignWarn', linehl='', numhl='' })
      vim.fn.sign_define('DapLogPoint', { text='', texthl='DiagnosticSignInfo', linehl='', numhl='' })
      vim.fn.sign_define('DapStopped', { text='', texthl='DiagnosticSignWarn', linehl='debugPC', numhl='' })
      vim.fn.sign_define('DapBreakpointRejected', { text='', texthl='DiagnosticSignHint', linehl='', numhl='' })

      -- Setup Mason integration for DAP
      require("mason-nvim-dap").setup({
        ensure_installed = { "delve" },
        automatic_installation = true,
        automatic_setup = true,
      })
      
      -- Keymaps for debugging
      vim.keymap.set("n", "<F5>", function() require("dap").continue() end)
      vim.keymap.set("n", "<F10>", function() require("dap").step_over() end)
      vim.keymap.set("n", "<F11>", function() require("dap").step_into() end)
      vim.keymap.set("n", "<F12>", function() require("dap").step_out() end)
      vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end)
      vim.keymap.set("n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end)
      vim.keymap.set("n", "<leader>dl", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end)
      vim.keymap.set("n", "<leader>dr", function() require("dap").repl.open() end)
      vim.keymap.set("n", "<leader>dt", function() require("dap-go").debug_test() end)
      vim.keymap.set("n", "<leader>do", function() require("dapui").open() end)
      vim.keymap.set("n", "<leader>dc", function() require("dapui").close() end)
    end,
  }
} 