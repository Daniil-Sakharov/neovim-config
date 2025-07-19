return {
  -- Встроенная документация и подсказки
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        plugins = {
          marks = false,      -- Отключаем для экономии ресурсов
          registers = false,  -- Отключаем для экономии ресурсов
          spelling = {
            enabled = false,  -- Отключаем для экономии ресурсов
            suggestions = 10, -- Уменьшаем количество предлагаемых исправлений
          },
          presets = {
            operators = false,    -- Отключаем для экономии ресурсов
            motions = false,      -- Отключаем для экономии ресурсов
            text_objects = false, -- Отключаем для экономии ресурсов
            windows = true,      -- Оставляем подсказки по командам окон
            nav = true,          -- Оставляем навигационные команды
            z = false,           -- Отключаем для экономии ресурсов
            g = false,           -- Отключаем для экономии ресурсов
          },
        },
        popup_mappings = {
          scroll_down = "<c-d>",
          scroll_up = "<c-u>",
        },
        window = {
          border = "none",       -- Убираем границы для ускорения отрисовки
          position = "bottom",      -- bottom, top
          margin = { 1, 0, 1, 0 },  -- отступы сверху, справа, снизу, слева
          padding = { 1, 2, 1, 2 }, -- padding внутри окна
        },
        layout = {
          height = { min = 4, max = 15 }, -- Уменьшаем максимальную высоту
          width = { min = 20, max = 40 }, -- Уменьшаем максимальную ширину
          spacing = 3,
        },
        hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " },
        triggers_blacklist = {
          i = { "j", "k" },
          v = { "j", "k" },
        },
        -- Отключаем подсветку для экономии ресурсов
        icons = {
          breadcrumb = "»", -- Символ для хлебных крошек
          separator = "➜", -- Символ для разделителя
          group = "+", -- Символ для группы
        },
        disable = {
          buftypes = {"quickfix"},
          filetypes = { "TelescopePrompt", "alpha", "NvimTree", "lazy" },
        },
      })
    end
  },

  -- Уведомления
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      local notify = require("notify")
      notify.setup({
        background_colour = "#000000",
        fps = 30, -- Уменьшаем частоту кадров
        icons = {
          ERROR = "",
          WARN = "",
          INFO = "",
          DEBUG = "",
          TRACE = "✎",
        },
        level = 3, -- Показываем только важные уведомления
        minimum_width = 30, -- Уменьшаем минимальную ширину
        render = "minimal", -- Используем минимальный рендеринг
        stages = "static", -- Отключаем анимацию для экономии ресурсов
        timeout = 2000, -- Уменьшаем время отображения
        top_down = true,
        max_height = function()
          return math.floor(vim.o.lines * 0.5) -- Ограничиваем максимальную высоту
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.5) -- Ограничиваем максимальную ширину
        end,
      })
      
      vim.notify = notify
    end
  },

  -- Информационная панель с индикаторами - отключаем для экономии ресурсов
  {
    "b0o/incline.nvim",
    enabled = false, -- Полностью отключаем плагин
  },

  -- Пользовательский интерфейс автодополнения
  {
    "onsails/lspkind.nvim",
    event = "VeryLazy",
    config = function()
      require("lspkind").init({
        mode = "symbol", -- Используем только символы без текста для экономии ресурсов
        preset = "codicons",
        symbol_map = {
          Text = "T",
          Method = "M",
          Function = "F",
          Constructor = "C",
          Field = "f",
          Variable = "V",
          Class = "C",
          Interface = "I",
          Module = "M",
          Property = "P",
          Unit = "U",
          Value = "v",
          Enum = "E",
          Keyword = "K",
          Snippet = "S",
          Color = "C",
          File = "F",
          Reference = "R",
          Folder = "D",
          EnumMember = "E",
          Constant = "C",
          Struct = "S",
          Event = "E",
          Operator = "O",
          TypeParameter = "T",
        },
        -- Отключаем дополнительные функции
        before = function() return "" end,
        after = function() return "" end,
      })
    end
  },

  -- Всплывающие подсказки по коду с мини-картой - отключаем для экономии ресурсов
  {
    "lewis6991/hover.nvim",
    enabled = false, -- Полностью отключаем плагин
  },

  -- Красивое дерево диагностики
  {
    "folke/trouble.nvim",
    event = "VeryLazy", -- Загружаем только при необходимости
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup({
        position = "bottom",
        height = 8, -- Уменьшаем высоту
        width = 40, -- Уменьшаем ширину
        icons = false, -- Отключаем иконки для экономии ресурсов
        mode = "workspace_diagnostics",
        fold_open = "+",
        fold_closed = "-",
        group = true,
        padding = false, -- Отключаем отступы для экономии ресурсов
        action_keys = {
          close = "q",
          cancel = "<esc>",
          refresh = "r",
          jump = { "<cr>", "<tab>" },
          open_split = { "<c-s>" },
          open_vsplit = { "<c-v>" },
          open_tab = { "<c-t>" },
          jump_close = { "o" },
          toggle_mode = "m",
          toggle_preview = "P",
          hover = "K",
          preview = "p",
          close_folds = { "zM", "zm" },
          open_folds = { "zR", "zr" },
          toggle_fold = { "zA", "za" },
          previous = "k",
          next = "j"
        },
        indent_lines = false, -- Отключаем линии отступов для экономии ресурсов
        auto_open = false,
        auto_close = false,
        auto_preview = false, -- Отключаем автоматический предпросмотр для экономии ресурсов
        auto_fold = true, -- Автоматически сворачиваем для экономии ресурсов
        signs = {
          error = "E",
          warning = "W",
          hint = "H",
          information = "I",
          other = "O"
        },
        use_diagnostic_signs = false
      })
      
      -- Горячие клавиши
      vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { desc = "Показать/скрыть диагностику" })
      vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { desc = "Диагностика проекта" })
      vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", { desc = "Диагностика документа" })
      vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { desc = "Список расположений" })
      vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { desc = "Quickfix список" })
      vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", { desc = "Ссылки на символ" })
    end
  }
} 