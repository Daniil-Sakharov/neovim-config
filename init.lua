-- Basic Config
require("core.configs")
require("core.mappings")
require("core.lazy")

-- Включаем inlay hints (типы переменных и подсказки)
vim.g.inlay_hints_enabled = true

-- Принудительно включаем подсказки типов для Go
vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost", "InsertLeave"}, {
  pattern = {"*.go"},
  callback = function(args)
    local bufnr = args.buf
    
    -- Принудительно включаем inlay hints тремя разными способами
    vim.defer_fn(function()
      -- Способ 1: через LSP клиент
      local clients = vim.lsp.get_active_clients({bufnr = bufnr})
      for _, client in ipairs(clients) do
        if client.name == "gopls" and client.server_capabilities.inlayHintProvider then
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true)
          elseif vim.lsp.buf.inlay_hint then
            vim.lsp.buf.inlay_hint(true)
          end
        end
      end
      
      -- Способ 2: прямая команда Neovim
      vim.cmd("silent! lua if vim.lsp.inlay_hint then vim.lsp.inlay_hint.enable(" .. bufnr .. ", true) end")
      
      -- Способ 3: через API функцию (для Neovim 0.11+)
      pcall(function() 
        if vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(bufnr, true)
        end
      end)
    end, 1000)
  end,
  group = vim.api.nvim_create_augroup("ForceGoInlayHintsAlways", { clear = true })
})

-- Создаем автокоманду для включения inlay hints после загрузки LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    -- Проверяем, что это Go файл
    local buf = args.buf
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    if ft == "go" then
      -- Включаем inlay hints с задержкой
      vim.defer_fn(function()
        pcall(function()
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true)
          elseif vim.lsp.buf.inlay_hint then
            vim.lsp.buf.inlay_hint(true)
          end
        end)
      end, 500)
    end
  end,
  group = vim.api.nvim_create_augroup("GoInlayHintsGlobal", { clear = true }),
})

-- Загружаем модуль для управления подсказками типов в Go
vim.defer_fn(function()
  pcall(function()
    -- Загружаем модуль подсказок типов если он существует
    local go_hints_ok, go_hints = pcall(require, "custom_go_inlay_hints")
    if go_hints_ok then
      go_hints.setup()
    end
    
    -- Создаем пользовательскую команду для диагностики подсказок типов
    vim.api.nvim_create_user_command("DiagnoseGoInlayHints", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_active_clients({bufnr = bufnr})
      local gopls_found = false
      
      for _, client in ipairs(clients) do
        if client.name == "gopls" then
          gopls_found = true
          print("gopls найден, проверяем поддержку подсказок типов...")
          
          if client.server_capabilities.inlayHintProvider then
            print("gopls поддерживает inlay hints")
            
            -- Принудительно включаем подсказки
            if vim.lsp.inlay_hint then
              vim.lsp.inlay_hint.enable(bufnr, true)
              print("Inlay hints включены через vim.lsp.inlay_hint")
            elseif vim.lsp.buf.inlay_hint then
              vim.lsp.buf.inlay_hint(bufnr, true)
              print("Inlay hints включены через vim.lsp.buf.inlay_hint")
            else
              print("API для inlay hints не найден!")
            end
          else
            print("gopls НЕ поддерживает inlay hints!")
          end
          
          -- Выводим версию gopls
          vim.system({"gopls", "version"}, {}, function(obj)
            print("Версия gopls: " .. (obj.stdout or "неизвестно"))
          end)
        end
      end
      
      if not gopls_found then
        print("gopls не найден! Перезапустите LSP командой :LspStart gopls")
      end
    end, {})
    
    -- Команда для принудительного перезапуска gopls
    vim.api.nvim_create_user_command("RestartGopls", function()
      vim.cmd("LspStop gopls")
      vim.defer_fn(function()
        vim.cmd("LspStart gopls")
        
        vim.defer_fn(function()
          local bufnr = vim.api.nvim_get_current_buf()
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(bufnr, true)
          end
        end, 1000)
      end, 500)
    end, {})
  end)
end, 2000)

-- Принудительно исправляем проблему с запятой
vim.cmd([[
  " Удаляем все возможные маппинги запятой
  silent! iunmap ,
  " Устанавливаем запятую как обычный символ
  inoremap <silent> , <Char-44>
]])

-- Создаем таймер для периодического исправления запятой
local comma_timer = vim.loop.new_timer()
comma_timer:start(1000, 1000, vim.schedule_wrap(function()
  -- Проверяем и исправляем маппинг запятой каждую секунду
  vim.cmd([[
    silent! iunmap ,
    inoremap <silent> , <Char-44>
  ]])
end))

-- Восстанавливаем клавиши leader+e и leader+q после загрузки всех плагинов
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Небольшая задержка для уверенности, что все плагины загрузились
    vim.defer_fn(function()
      -- Принудительно устанавливаем глобальные клавиши
      vim.cmd([[
        " Удаляем существующие маппинги, если они есть
        silent! nunmap <buffer> <leader>e
        silent! nunmap <buffer> <leader>q
        silent! nunmap <leader>e
        silent! nunmap <leader>q
        
        " Устанавливаем новые маппинги глобально
        nnoremap <silent> <leader>e :Neotree toggle<CR>
        nnoremap <silent> <leader>q :bd<CR>
      ]])
    end, 300) -- 300 мс задержки для уверенности
    
    -- Повторяем с большей задержкой для полной уверенности
    vim.defer_fn(function()
      vim.cmd([[
        " Удаляем существующие маппинги, если они есть
        silent! nunmap <buffer> <leader>e
        silent! nunmap <buffer> <leader>q
        silent! nunmap <leader>e
        silent! nunmap <leader>q
        
        " Устанавливаем новые маппинги глобально
        nnoremap <silent> <leader>e :Neotree toggle<CR>
        nnoremap <silent> <leader>q :bd<CR>
      ]])
    end, 1000) -- 1000 мс задержки для максимальной уверенности
  end,
  group = vim.api.nvim_create_augroup("GlobalKeymapsCheck", { clear = true }),
  pattern = "*",
  once = true, -- Выполняем только один раз при запуске
})

-- Принудительно устанавливаем клавиши leader+e и leader+q при входе в Go файлы
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"go", "gomod"},
  callback = function()
    -- Удаляем возможные конфликтующие маппинги
    pcall(vim.keymap.del, "n", "<leader>e", { buffer = true })
    pcall(vim.keymap.del, "n", "<leader>q", { buffer = true })
    
    -- Устанавливаем наши маппинги для текущего буфера
    vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set("n", "<leader>q", ":bd<CR>", { noremap = true, silent = true, buffer = true })
    
    -- Повторяем с задержкой для уверенности
    vim.defer_fn(function()
      pcall(vim.keymap.del, "n", "<leader>e", { buffer = true })
      pcall(vim.keymap.del, "n", "<leader>q", { buffer = true })
      vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true, silent = true, buffer = true })
      vim.keymap.set("n", "<leader>q", ":bd<CR>", { noremap = true, silent = true, buffer = true })
    end, 100)
  end,
  group = vim.api.nvim_create_augroup("GoKeymapsRestore", { clear = true }),
})

-- Создаем команду для принудительного восстановления клавиш
vim.api.nvim_create_user_command("RestoreGoKeys", function()
  -- Удаляем возможные конфликтующие маппинги
  pcall(vim.keymap.del, "n", "<leader>e", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>q", { buffer = true })
  
  -- Устанавливаем наши маппинги для текущего буфера
  vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true, silent = true, buffer = true })
  vim.keymap.set("n", "<leader>q", ":bd<CR>", { noremap = true, silent = true, buffer = true })
end, {})

-- Создаем автокоманду для восстановления клавиш при смене буфера
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  callback = function()
    -- Восстанавливаем клавиши с небольшой задержкой
    vim.defer_fn(function()
      -- Проверяем, есть ли маппинги для leader+e и leader+q
      local maps = vim.api.nvim_get_keymap('n')
      local has_e = false
      local has_q = false
      
      for _, map in ipairs(maps) do
        if map.lhs == vim.g.mapleader .. "e" and map.rhs:match("Neotree") then
          has_e = true
        end
        if map.lhs == vim.g.mapleader .. "q" and map.rhs:match("bd") then
          has_q = true
        end
      end
      
      -- Если какой-то из маппингов отсутствует, восстанавливаем их
      if not (has_e and has_q) then
        pcall(vim.keymap.del, "n", "<leader>e", { buffer = true })
        pcall(vim.keymap.del, "n", "<leader>q", { buffer = true })
        vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true, silent = true, buffer = true })
        vim.keymap.set("n", "<leader>q", ":bd<CR>", { noremap = true, silent = true, buffer = true })
      end
    end, 50)
  end,
  group = vim.api.nvim_create_augroup("KeymapsFixBuffer", { clear = true }),
})

-- Гарантируем прозрачность TabLineFill и BufferLineFill для bufferline/tabline
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.cmd [[hi TabLineFill guibg=NONE ctermbg=NONE]]
    vim.cmd [[hi BufferLineFill guibg=NONE ctermbg=NONE]]
  end
})
