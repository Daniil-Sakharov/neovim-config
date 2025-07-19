-- Этот файл исправляет подсветку и включает подсказки типов в Go файлах
-- Загружается после всех плагинов для гарантированного применения настроек

-- Функция для настройки подсветки и подсказок типов
local function setup_go_highlighting_and_hints()
  -- Восстанавливаем стандартную подсветку переменных
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
      -- Отключаем семантические токены, которые могут конфликтовать с подсветкой
      vim.api.nvim_set_option_value("syntax", "ON", { scope = "local" })
      
      -- Устанавливаем правильные цвета для подсветки Go
      vim.cmd([[
        hi! goField guifg=#d7d7ff ctermfg=189
        hi! goVariable guifg=#5fffff ctermfg=87
        hi! goFunctionCall guifg=#d7afff ctermfg=183
        hi! goFunction guifg=#00d7ff ctermfg=45
        hi! goType guifg=#00ffaf ctermfg=49
        hi! goVarDefs guifg=#5fffff ctermfg=87
      ]])
    end,
    group = vim.api.nvim_create_augroup("GoHighlightFix", { clear = true }),
  })

  -- Функция для принудительного включения inlay hints
  local function force_enable_inlay_hints(bufnr)
    bufnr = bufnr or 0
    
    -- Получаем активные LSP клиенты для буфера
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    local has_gopls = false
    
    -- Проверяем, есть ли gopls среди клиентов
    for _, client in ipairs(clients) do
      if client.name == "gopls" then
        has_gopls = true
        -- Проверяем поддержку inlay hints
        if client.server_capabilities.inlayHintProvider then
          -- Пробуем включить inlay hints
          pcall(function()
            if vim.lsp.inlay_hint then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
              print("Inlay hints enabled for buffer " .. bufnr)
            elseif vim.lsp.buf.inlay_hint then
              vim.lsp.buf.inlay_hint(bufnr, true)
              print("Legacy inlay hints enabled for buffer " .. bufnr)
            end
          end)
        else
          print("gopls не поддерживает inlay hints")
        end
        break
      end
    end
    
    if not has_gopls then
      -- Если gopls не запущен, пробуем запустить его
      vim.cmd("LspStart gopls")
      -- Повторяем попытку через секунду
      vim.defer_fn(function()
        force_enable_inlay_hints(bufnr)
      end, 1000)
    end
  end
  
  -- Создаем команду для ручного включения подсказок типов
  vim.api.nvim_create_user_command("GoInlayHints", function()
    force_enable_inlay_hints(0)
  end, {})
  
  -- Автоматически включаем подсказки типов при открытии Go файлов
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function(args)
      -- Даем время LSP серверу запуститься
      vim.defer_fn(function()
        force_enable_inlay_hints(args.buf)
      end, 1000)
      
      -- Повторяем с большей задержкой для надежности
      vim.defer_fn(function()
        force_enable_inlay_hints(args.buf)
      end, 3000)
    end,
    group = vim.api.nvim_create_augroup("GoInlayHintsAutoEnable", { clear = true }),
  })
  
  -- Включаем подсказки типов при подключении LSP сервера
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end
      
      if client.name == "gopls" then
        vim.defer_fn(function()
          force_enable_inlay_hints(args.buf)
        end, 500)
      end
    end,
    group = vim.api.nvim_create_augroup("GoLspInlayHints", { clear = true }),
  })
  
  -- Создаем таймер для периодической проверки и включения подсказок типов
  local timer = vim.loop.new_timer()
  timer:start(5000, 10000, vim.schedule_wrap(function()
    -- Проходим по всем буферам
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(bufnr) then
        local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
        if ft == "go" then
          force_enable_inlay_hints(bufnr)
        end
      end
    end
  end))
  
  -- Принудительно запускаем для всех открытых Go буферов
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      if ft == "go" then
        -- Восстанавливаем подсветку
        vim.api.nvim_set_option_value("syntax", "ON", { scope = "buffer", buf = bufnr })
        
        -- Включаем подсказки типов с задержкой
        vim.defer_fn(function()
          force_enable_inlay_hints(bufnr)
        end, 1000)
      end
    end
  end
end

-- Запускаем настройку с задержкой после загрузки всех плагинов
vim.defer_fn(setup_go_highlighting_and_hints, 500) 