return {
  -- Комментирование кода
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup({
        -- Включить поддержку Treesitter
        pre_hook = function(ctx)
          local U = require("Comment.utils")
          local location = nil
          if ctx.ctype == U.ctype.block then
            location = require("ts_context_commentstring.utils").get_cursor_location()
          elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
            location = require("ts_context_commentstring.utils").get_visual_start_location()
          end
          return require("ts_context_commentstring.internal").calculate_commentstring {
            key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
            location = location,
          }
        end,
        -- Горячие клавиши комментирования (для русской раскладки)
        toggler = {
          line = 'gcc',
          block = 'gbc',
        },
        opleader = {
          line = 'gc',
          block = 'gb',
        },
      })
    end,
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    }
  },

  -- Быстрая навигация между окнами
  {
    "christoomey/vim-tmux-navigator",
    event = "VeryLazy",
    config = function()
      vim.g.tmux_navigator_no_mappings = 1
      -- Mappings already handled in core/mappings.lua
    end
  },

  -- Автоматические отступы и форматирование
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          go = { "goimports", "gofmt" },
          javascript = { { "prettierd", "prettier" } },
          typescript = { { "prettierd", "prettier" } },
          json = { { "prettierd", "prettier" } },
          html = { { "prettierd", "prettier" } },
          css = { { "prettierd", "prettier" } },
          markdown = { { "prettierd", "prettier" } },
          yaml = { { "prettierd", "prettier" } },
        },
        -- Автоматическое форматирование при сохранении файла
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end
  },

  -- Подсветка строк с изменениями (indent guides)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = {
          enabled = true,
          show_start = true,
          show_end = false,
          highlight = { "Function", "Label" },
        },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
          },
        },
      })
    end
  },
  
  -- Подсветка одинаковых слов и символов
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      require("illuminate").configure({
        providers = {
          'lsp',
          'treesitter',
          'regex',
        },
        delay = 100,
        filetypes_denylist = {
          'dirbuf',
          'dirvish',
          'fugitive',
          'neo-tree',
        },
        min_count_to_highlight = 2,
      })
    end
  },
  
  -- Умное выделение текста (расширенные текстовые объекты)
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Используйте cs"' для замены "" на ''
        -- Используйте ds" для удаления ""
        -- Используйте ysiw] для обертывания слова в []
      })
    end
  },
  
  -- Расширенный режим поиска 
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      require("flash").setup({
        modes = {
          char = {
            enabled = true,
            jump_labels = true,
          }
        },
        label = {
          uppercase = true,
        },
      })
      
      -- Горячие клавиши для поиска
      vim.keymap.set({"n", "x", "o"}, "s", function()
        require("flash").jump()
      end, { desc = "Поиск в документе"})
      
      vim.keymap.set({"n", "x", "o"}, "S", function()
        require("flash").treesitter()
      end, { desc = "Поиск по структуре документа (Treesitter)"})
    end,
  }
} 