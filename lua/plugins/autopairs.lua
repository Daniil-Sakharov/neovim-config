return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      
      autopairs.setup({
        check_ts = true, -- Учитывать treesitter при работе с парами
        ts_config = {
          lua = {'string'},  -- не добавлять пары в строках lua
          javascript = {'template_string'},
          java = false,  -- отключить проверки для java
        },
        disable_filetype = { "TelescopePrompt", "vim" }, -- отключить для некоторых типов файлов
        
        -- Быстрые настройки для скобок
        fast_wrap = {
          map = '<M-e>',     -- Alt+e для быстрого оборачивания текста скобками
          chars = { '{', '[', '(', '"', "'" },
          pattern = [=[[%'%"%)%>%]%)%}%,]]=],
          end_key = '$',
          keys = 'qwertyuiopzxcvbnmasdfghjkl',
          check_comma = true,
          highlight = 'Search',
          highlight_grey='Comment'
        },
      })
      
      -- Интеграция с cmp для автодополнения
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp_status_ok, cmp = pcall(require, 'cmp')
      if cmp_status_ok then
        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
      end
      
      -- Добавление собственных правил
      local Rule = require('nvim-autopairs.rule')
      
      -- Добавление пробелов между скобками при нажатии на пробел
      autopairs.add_rules({
        Rule(' ', ' ')
          :with_pair(function(opts)
            local pair = opts.line:sub(opts.col - 1, opts.col)
            return vim.tbl_contains({ '()', '[]', '{}' }, pair)
          end),
        Rule('( ', ' )')
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%)') ~= nil
          end)
          :use_key(')'),
        Rule('{ ', ' }')
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%}') ~= nil
          end)
          :use_key('}'),
        Rule('[ ', ' ]')
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%]') ~= nil
          end)
          :use_key(']')
      })
      
      -- Автоматически добавлять запятую в конце строки для JavaScript/TypeScript объектов
      autopairs.add_rules({
        Rule(',', '')
          :with_move(function(opts) return opts.char == ',' end)
          :with_pair(function() return false end)
          :with_cr(function() return false end)
          :with_del(function() return false end)
          :use_key(',')
      })
    end
  }
} 