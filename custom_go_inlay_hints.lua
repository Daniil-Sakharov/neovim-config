-- Модуль для улучшенного управления подсказками типов в Go файлах
-- Использует современный API Neovim 0.10+

local M = {}

-- Функция для безопасного включения inlay hints
local function safe_enable_inlay_hints(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  
  -- Проверяем, что это Go файл
  local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  if ft ~= "go" then
    return false
  end
  
  -- Проверяем наличие активного gopls клиента
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })
  if #clients == 0 then
    return false
  end
  
  -- Включаем inlay hints с использованием современного API
  local success = pcall(function()
    if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      return true
    end
  end)
  
  return success
end

-- Функция для включения inlay hints во всех Go буферах
function M.enable_for_all_go_buffers()
  local enabled_count = 0
  
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      if safe_enable_inlay_hints(bufnr) then
        enabled_count = enabled_count + 1
      end
    end
  end
  
  if enabled_count > 0 then
    print(string.format("Inlay hints enabled for %d Go buffer(s)", enabled_count))
  end
  
  return enabled_count
end

-- Функция для проверки статуса inlay hints
function M.check_inlay_hints_status()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  
  if ft ~= "go" then
    print("Not a Go file")
    return
  end
  
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })
  if #clients == 0 then
    print("No gopls client attached")
    return
  end
  
  local client = clients[1]
  local supports_hints = client.server_capabilities.inlayHintProvider
  
  local enabled = false
  if vim.lsp.inlay_hint and vim.lsp.inlay_hint.is_enabled then
    enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
  end
  
  print(string.format("Gopls inlay hint support: %s", supports_hints and "Yes" or "No"))
  print(string.format("Inlay hints enabled: %s", enabled and "Yes" or "No"))
  print(string.format("Buffer: %d, Client: %s", bufnr, client.name))
end

-- Функция для перезагрузки gopls и включения hints
function M.restart_gopls_with_hints()
  -- Получаем все Go буферы
  local go_buffers = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
      if ft == "go" then
        table.insert(go_buffers, bufnr)
      end
    end
  end
  
  -- Перезапускаем gopls
  vim.cmd("LspRestart gopls")
  
  -- Включаем hints с задержкой для всех Go буферов
  vim.defer_fn(function()
    for _, bufnr in ipairs(go_buffers) do
      safe_enable_inlay_hints(bufnr)
    end
    print(string.format("Gopls restarted and inlay hints enabled for %d buffer(s)", #go_buffers))
  end, 3000)
end

-- Функция для принудительного обновления конфигурации gopls
function M.force_update_gopls_config()
  for _, client in ipairs(vim.lsp.get_clients({ name = "gopls" })) do
    -- Обновляем настройки hints
    if client.config.settings and client.config.settings.gopls then
      client.config.settings.gopls.hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      }
      
      -- Отправляем обновленную конфигурацию
      client.notify("workspace/didChangeConfiguration", {
        settings = client.config.settings
      })
      
      print("Gopls configuration updated")
    end
  end
end

-- Настройка автокоманд и команд
function M.setup()
  -- Создаем пользовательские команды
  vim.api.nvim_create_user_command("GoEnableInlayHints", M.enable_for_all_go_buffers, {
    desc = "Enable inlay hints for all Go buffers"
  })
  
  vim.api.nvim_create_user_command("GoCheckInlayHints", M.check_inlay_hints_status, {
    desc = "Check inlay hints status for current buffer"
  })
  
  vim.api.nvim_create_user_command("GoRestartLspHints", M.restart_gopls_with_hints, {
    desc = "Restart gopls and enable inlay hints"
  })
  
  vim.api.nvim_create_user_command("GoUpdateConfig", M.force_update_gopls_config, {
    desc = "Force update gopls configuration"
  })
  
  -- Создаем группу автокоманд
  local augroup = vim.api.nvim_create_augroup("CustomGoInlayHints", { clear = true })
  
  -- Включаем hints при подключении LSP к Go файлам
  vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or client.name ~= "gopls" then
        return
      end
      
      local bufnr = args.buf
      local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
      if ft ~= "go" then
        return
      end
      
      -- Включаем hints с задержкой
      vim.defer_fn(function()
        safe_enable_inlay_hints(bufnr)
      end, 2000)
    end,
  })
  
  -- Периодически проверяем и включаем hints
  vim.api.nvim_create_autocmd({"BufEnter", "InsertLeave"}, {
    group = augroup,
    pattern = "*.go",
    callback = function()
      vim.defer_fn(function()
        safe_enable_inlay_hints(0)
      end, 500)
    end,
  })
  
  -- Создаем маппинги
  vim.keymap.set("n", "<leader>ih", M.enable_for_all_go_buffers, { desc = "Enable Go inlay hints" })
  vim.keymap.set("n", "<leader>ic", M.check_inlay_hints_status, { desc = "Check inlay hints status" })
  vim.keymap.set("n", "<leader>ir", M.restart_gopls_with_hints, { desc = "Restart gopls with hints" })
  
  print("Custom Go inlay hints module loaded")
end

return M 