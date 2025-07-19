return {
  -- Отключаем nvim-notify и используем стандартные уведомления в командной строке
  {
    "rcarriga/nvim-notify",
    enabled = false, -- Полностью отключаем плагин
  },
  
  -- Настраиваем уведомления Neovim для отображения в командной строке
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    enabled = false, -- Отключаем плагин noice если он установлен
  },
  
  -- Настройка для возврата к стандартным уведомлениям в командной строке
  {
    "nvim-lua/plenary.nvim",
    config = function()
      -- Сохраняем оригинальную функцию уведомлений
      local original_notify = vim.notify
      
      -- Отключаем предупреждения о устаревших функциях
      local disabled_warnings = {
        "Neoscroll:",
        "the function signature scroll",
        "deprecated",
        "favour of the new",
        "Defining diagnostic signs with",
        "Invalid settings:",
        "fieldalignment",
        "hover over struct fields",
        "unexpected setting",
        "There are issues with your config"
      }
      
      -- Переопределяем функцию уведомлений для использования командной строки
      vim.notify = function(msg, level, opts)
        -- Проверяем, содержит ли сообщение текст из списка отключенных предупреждений
        if msg then
          for _, warning in ipairs(disabled_warnings) do
            if msg:match(warning) then
              return -- Не показываем предупреждение
            end
          end
        end
        
        -- Преобразуем уровень в текст для вывода в командную строку
        local level_str = ""
        if level == vim.log.levels.ERROR then
          level_str = "ERROR: "
        elseif level == vim.log.levels.WARN then
          level_str = "WARN: "
        elseif level == vim.log.levels.INFO then
          level_str = "INFO: "
        end
        
        -- Выводим сообщение в командную строку
        if msg then
          -- Используем pcall для защиты от ошибок при выполнении команды
          pcall(function()
            vim.cmd("echomsg '" .. level_str .. (tostring(msg):gsub("'", "''")) .. "'")
          end)
        end
      end
    end
  }
} 