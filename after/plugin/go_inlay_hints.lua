-- Этот файл загружается в самом конце и принудительно включает подсказки типов для Go файлов

-- Глобальная переменная для отслеживания статуса подсказок типов
vim.g.go_inlay_hints_enabled = true

-- Функция для включения подсказок типов для всех Go буферов
local function enable_go_inlay_hints_now()
  -- Проходим по всем буферам
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    -- Проверяем, что буфер действительный
    if vim.api.nvim_buf_is_valid(bufnr) then
      -- Проверяем, что это Go файл
      local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      if ft == "go" then
        -- Получаем активные LSP клиенты для этого буфера
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
        for _, client in ipairs(clients) do
          if client.name == "gopls" then
            -- Проверяем поддержку inlay hints
            if client.server_capabilities.inlayHintProvider then
              -- Пробуем все возможные способы включения подсказок типов
              pcall(function()
                -- Для Neovim 0.10+
                if vim.lsp.inlay_hint then
                  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                  print("Подсказки типов включены для буфера " .. bufnr)
                -- Для старых версий Neovim
                elseif vim.lsp.buf.inlay_hint then
                  vim.lsp.buf.inlay_hint(bufnr, true)
                  print("Legacy подсказки типов включены для буфера " .. bufnr)
                end
              end)
            end
            break
          end
        end
      end
    end
  end
end

-- Функция для перезапуска gopls и включения подсказок типов
local function restart_gopls_and_enable_hints()
  -- Перезапускаем gopls
  vim.cmd("LspRestart gopls")
  
  -- Включаем подсказки типов с задержкой
  vim.defer_fn(function()
    enable_go_inlay_hints_now()
  end, 1500)
end

-- Создаем команды для управления подсказками типов
vim.api.nvim_create_user_command("GoInlayHintsEnable", function()
  vim.g.go_inlay_hints_enabled = true
  enable_go_inlay_hints_now()
end, {})

vim.api.nvim_create_user_command("GoInlayHintsDisable", function()
  vim.g.go_inlay_hints_enabled = false
  
  -- Проходим по всем буферам и отключаем подсказки типов
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      pcall(function()
        if vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
        end
      end)
    end
  end
end, {})

vim.api.nvim_create_user_command("GoInlayHintsToggle", function()
  if vim.g.go_inlay_hints_enabled then
    vim.cmd("GoInlayHintsDisable")
    print("Go inlay hints disabled")
  else
    vim.cmd("GoInlayHintsEnable")
    print("Go inlay hints enabled")
  end
end, {})

vim.api.nvim_create_user_command("GoLspRestart", restart_gopls_and_enable_hints, {})

-- Создаем маппинги для управления подсказками типов
vim.keymap.set("n", "<leader>ht", ":GoInlayHintsToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>hr", ":GoLspRestart<CR>", { noremap = true, silent = true })

-- Автоматически включаем подсказки типов при открытии Go файлов
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    if vim.g.go_inlay_hints_enabled then
      vim.defer_fn(function()
        enable_go_inlay_hints_now()
      end, 1000)
    end
  end,
  group = vim.api.nvim_create_augroup("GoInlayHintsAuto", { clear = true }),
})

-- Включаем подсказки типов при каждом изменении буфера
vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
  pattern = "*.go",
  callback = function()
    if vim.g.go_inlay_hints_enabled then
      vim.defer_fn(function()
        enable_go_inlay_hints_now()
      end, 500)
    end
  end,
  group = vim.api.nvim_create_augroup("GoInlayHintsRefresh", { clear = true }),
})

-- Включаем подсказки типов с периодичностью в 10 секунд для Go файлов
local timer = vim.loop.new_timer()
timer:start(5000, 10000, vim.schedule_wrap(function()
  if vim.g.go_inlay_hints_enabled then
    enable_go_inlay_hints_now()
  end
end))

-- Запускаем непосредственно после загрузки плагина
vim.defer_fn(function()
  enable_go_inlay_hints_now()
end, 1000) 