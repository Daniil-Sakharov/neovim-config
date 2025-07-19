-- Яркая цветовая схема для Go
return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        -- Стиль темы: day, night, storm, moon или дневной
        style = "night",
        -- Включение прозрачности
        transparent = false,
        -- Использовать курсив для комментариев и атрибутов
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = { bold = true },
          variables = {},
          sidebars = "dark",
          floats = "dark",
        },
        -- Яркий вариант подсветки
        light_style = "day",
        -- Расширенные настройки цветов
        on_colors = function(colors)
          -- Усиление контраста для лучшей читаемости
          colors.comment = "#7389b3"       -- Более яркие комментарии
          colors.fg_gutter = "#627085"     -- Более яркие номера строк
          colors.git.change = "#b5c2ff"    -- Более яркие изменения git
          
          -- Добавляем проверку на существование полей перед использованием
          if colors.git then
            colors.git.add = "#8eff9e"     -- Более яркие добавления git
            colors.git.delete = "#ff5370"  -- Более яркие удаления git
          end
        end,
        -- Переопределение стандартных групп подсветки
        on_highlights = function(highlights, colors)
          -- Улучшенная подсветка для Go
          highlights.goPackageName = { fg = "#f7768e", italic = true, bold = true } -- Яркий малиновый
          highlights.goImportString = { fg = "#2ac3de", italic = true } -- Яркий голубой
          highlights.goFunctionCall = { fg = "#7dcfff", bold = true }   -- Яркий синий
          highlights.goMethodCall = { fg = "#bb9af7", bold = true }     -- Яркий фиолетовый
          highlights.goParamType = { fg = "#ff9e64", italic = true }    -- Яркий оранжевый
          highlights.goField = { fg = "#9ece6a", italic = false }       -- Яркий зеленый
          highlights.goReceiverType = { fg = "#e0af68", bold = true }   -- Яркий желтый
          highlights.goTypeConstructor = { fg = "#f7768e", bold = true } -- Яркий красный
          highlights.goTypeName = { fg = "#ff9e64", bold = true }       -- Яркий оранжевый
          highlights.goFloatDec = { fg = "#2ac3de", bold = true }       -- Голубой жирный
          highlights.goIntDec = { fg = "#9ece6a", bold = true }         -- Зеленый жирный
          highlights.goBoolean = { fg = "#ff9e64", bold = true }        -- Оранжевый жирный
          highlights.goVarDefs = { fg = "#bb9af7", bold = false }       -- Фиолетовый
          highlights.goVarAssign = { fg = "#73daca", bold = false }     -- Аква
          highlights.goDeclType = { fg = "#2ac3de", bold = true, italic = true } -- Голубой
          highlights.goVarArgs = { fg = "#e0af68", bold = false }       -- Желтый
        end,
      })
    
      -- Устанавливаем текущую цветовую схему
      vim.cmd[[colorscheme tokyonight]]

      -- Создаем автокоманду для файлов Go чтобы применять специальные правила
      vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
        pattern = {"*.go"},
        callback = function()
          -- Добавляем специальные подсветки для Go кода
          vim.api.nvim_set_hl(0, "@type.go", { fg = "#ff9e64", bold = true })
          vim.api.nvim_set_hl(0, "@function.go", { fg = "#7dcfff", bold = true })
          vim.api.nvim_set_hl(0, "@variable.go", { fg = "#73daca", italic = false })
          vim.api.nvim_set_hl(0, "@keyword.go", { fg = "#f7768e", bold = true, italic = true })
          vim.api.nvim_set_hl(0, "@string.go", { fg = "#9ece6a", italic = true })
          vim.api.nvim_set_hl(0, "@comment.go", { fg = "#7389b3", italic = true })
          vim.api.nvim_set_hl(0, "@constant.go", { fg = "#bb9af7", bold = true })
          vim.api.nvim_set_hl(0, "@field.go", { fg = "#2ac3de", italic = false })
          vim.api.nvim_set_hl(0, "@parameter.go", { fg = "#e0af68", italic = true })
        end
      })
    end
  }
} 