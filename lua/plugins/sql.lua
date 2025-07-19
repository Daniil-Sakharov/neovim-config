return {
  {
    "nanotee/sqls.nvim",
    config = function()
      require('lspconfig').sqls.setup({
        on_attach = function(client, bufnr)
          require('sqls').on_attach(client, bufnr)
          
          -- Map SQL specific commands
          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "<leader>sq", "<cmd>SqlsExecuteQuery<CR>", opts)
          vim.keymap.set("v", "<leader>sq", "<cmd>SqlsExecuteQuery<CR>", opts)
          vim.keymap.set("n", "<leader>sc", "<cmd>SqlsExecuteCurrentQuery<CR>", opts)
        end,
      })
    end
  },
  {
    -- SQL formatter integration
    "b4b4r07/vim-sqlfmt",
    ft = {"sql"},
    config = function()
      vim.g.sqlfmt_command = "sqlformat"
      vim.g.sqlfmt_options = "-r -k upper"
      vim.g.sqlfmt_auto = true
    end
  },
  {
    -- Database UI
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion"
    },
    config = function()
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      vim.g.db_ui_auto_execute_table_helpers = 1
      
      -- Add keyboard shortcuts for database operations
      vim.keymap.set("n", "<leader>db", "<cmd>DBUIToggle<CR>")
      vim.keymap.set("n", "<leader>df", "<cmd>DBUIFindBuffer<CR>")
      vim.keymap.set("n", "<leader>dr", "<cmd>DBUIRenameBuffer<CR>")
      vim.keymap.set("n", "<leader>dl", "<cmd>DBUILastQueryInfo<CR>")
    end
  },
  {
    -- Better syntax highlighting for SQL
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = opts.ensure_installed or {}
        opts.ensure_installed = vim.list_extend(opts.ensure_installed, { "sql" })
      end
    end
  }
} 