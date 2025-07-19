return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-go",
      "nvim-neotest/nvim-nio"
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-go")({
            -- Extra arguments for go test
            args = {"-v"},
            -- Test runner to use (go test, gotest, richgo, etc.)
            experimental = {
              test_table = true,
            },
            -- Show coverage as diagnostic signs
            diagnostic = {
              enabled = true,
            },
          })
        },
        -- Icons to use for test results
        icons = {
          passed = "✓",
          running = "🔄",
          failed = "✗",
          skipped = "⏭️",
          unknown = "?"
        },
        -- Highlight groups for different test states
        highlights = {
          passed = "Green",
          running = "Yellow",
          failed = "Red",
          skipped = "Blue",
        },
        -- Show console output in a floating window
        output = {
          enabled = true,
          open_on_run = true,
        },
        -- Status line integration
        status = {
          enabled = true,
          virtual_text = true,
          signs = true,
        },
        -- Configure the summary view
        summary = {
          enabled = true,
          expand_errors = true,
          follow = true,
          mappings = {
            expand = "o",
            expand_all = "O",
            jumpto = "<CR>",
            output = "r",
            run = "R",
            short = "p",
            stop = "s",
          },
        },
      })
    end
  }
} 