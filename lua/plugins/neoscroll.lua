-- Плавная прокрутка для <C-d>, <C-u>, <C-f>, <C-b> и т.д.
return {
  "karb94/neoscroll.nvim",
  event = "VeryLazy",
  config = function()
    local neoscroll = require("neoscroll")

    neoscroll.setup({
      easing_function = "quadratic", -- плавность
      hide_cursor = false,
      stop_eof = true,
      respect_scrolloff = true,
      cursor_scrolls_alone = true,
      performance_mode = false,
      pre_hook = nil,
      post_hook = nil,
      easing_function = nil,
    })
    
    -- Используем новый API для устранения предупреждения
    local map = {}
    
    -- Определяем время анимации
    local time = 150
    
    -- Helper функции для создания маппингов с новым API
    map['<C-u>'] = function() 
      neoscroll.scroll(-vim.wo.scroll, true, time)
    end
    
    map['<C-d>'] = function() 
      neoscroll.scroll(vim.wo.scroll, true, time)
    end
    
    map['<C-b>'] = function() 
      neoscroll.scroll(-vim.api.nvim_win_get_height(0), true, time)
    end
    
    map['<C-f>'] = function() 
      neoscroll.scroll(vim.api.nvim_win_get_height(0), true, time)
    end
    
    map['<C-y>'] = function() 
      neoscroll.scroll(-3, true, time)
    end
    
    map['<C-e>'] = function() 
      neoscroll.scroll(3, true, time)
    end
    
    map['zt'] = function() 
      neoscroll.zt(time)
    end
    
    map['zz'] = function() 
      neoscroll.zz(time)
    end
    
    map['zb'] = function() 
      neoscroll.zb(time)
    end
    
    -- Применяем маппинги
    for k, v in pairs(map) do
      vim.keymap.set('n', k, v, { silent = true })
    end
  end,
}

