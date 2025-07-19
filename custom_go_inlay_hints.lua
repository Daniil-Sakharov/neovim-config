-- Модуль для управления подсказками типов в Go файлах

local M = {}

-- Настройка конфигурации gopls для подсказок типов
function M.configure_gopls()
  -- Получаем доступ к lspconfig
  local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
  if not lspconfig_ok then
    print("lspconfig не найден")
    return
  end
  
  -- Перенастраиваем gopls с активацией всех подсказок типов
  lspconfig.gopls.setup({
    settings = {
      gopls = {
        -- Включаем все типы подсказок
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        -- Отключаем семантические токены, которые могут мешать подсказкам
        semanticTokens = false,
      },
    },
    -- Переопределяем on_attach для включения подсказок
    on_attach = function(client, bufnr)
      -- Отключаем семантические токены
      client.server_capabilities.semanticTokensProvider = nil
      
      -- Включаем подсказки типов
      if client.server_capabilities.inlayHintProvider then
        -- Принудительно включаем с задержкой для надежности
        vim.defer_fn(function()
          pcall(function()
            if vim.lsp.inlay_hint then
              vim.lsp.inlay_hint.enable(bufnr, true)
              print("Подсказки типов включены для буфера " .. bufnr)
            end
          end)
        end, 500)
      end
    end,
  })
  
  print("Gopls перенастроен для подсказок типов")
end

-- Функция для включения подсказок типов для всех Go буферов
function M.enable_for_all_buffers()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      if ft == "go" then
        -- Пробуем через прямой вызов
        pcall(function()
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(bufnr, true)
          elseif vim.lsp.buf.inlay_hint then
            vim.lsp.buf.inlay_hint(bufnr, true)
          end
        end)
      end
    end
  end
end

-- Функция для обновления настроек gopls клиента
function M.update_gopls_settings()
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.name == "gopls" then
      -- Обновляем настройки gopls
      client.config.settings = client.config.settings or {}
      client.config.settings.gopls = client.config.settings.gopls or {}
      client.config.settings.gopls.hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      }
      client.config.settings.gopls.semanticTokens = false
      
      -- Перезагружаем клиента
      client.notify("workspace/didChangeConfiguration", {
        settings = client.config.settings
      })
      
      print("Настройки gopls обновлены")
    end
  end
end

-- Функция для перезапуска gopls и включения подсказок
function M.restart_and_enable()
  -- Перезапускаем gopls
  vim.cmd("LspRestart gopls")
  
  -- Обновляем настройки и включаем подсказки типов с задержкой
  vim.defer_fn(function()
    M.update_gopls_settings()
    M.enable_for_all_buffers()
  end, 2000)
  
  print("Gopls перезапущен и подсказки типов будут включены")
end

-- Создаем команды
function M.setup()
  -- Включаем подсказки типов при загрузке модуля
  vim.defer_fn(function()
    M.configure_gopls()
    M.enable_for_all_buffers()
  end, 1000)
  
  -- Создаем команды для управления подсказками
  vim.api.nvim_create_user_command("GoRestartLspAndEnableHints", M.restart_and_enable, {})
  vim.api.nvim_create_user_command("GoEnableTypeHints", M.enable_for_all_buffers, {})
  
  -- Создаем таймер для периодического включения подсказок
  local timer = vim.loop.new_timer()
  timer:start(5000, 10000, vim.schedule_wrap(M.enable_for_all_buffers))
  
  -- Автоматически включаем при открытии Go файлов
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
      vim.defer_fn(M.enable_for_all_buffers, 1000)
    end,
    group = vim.api.nvim_create_augroup("GoTypeHintsModule", { clear = true }),
  })
  
  -- Включаем при сохранении и входе в буфер
  vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
    pattern = "*.go",
    callback = function()
      vim.defer_fn(M.enable_for_all_buffers, 500)
    end,
    group = vim.api.nvim_create_augroup("GoTypeHintsRefresh", { clear = true }),
  })
end

return M 