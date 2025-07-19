-- Принудительное включение подсказок типов для Go файлов
local M = {}

-- Функция для включения inlay hints
local function enable_inlay_hints(bufnr)
  bufnr = bufnr or 0
  
  -- Проверяем, что это Go файл
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if ft ~= "go" then
    return
  end
  
  -- Пробуем включить inlay hints разными способами
  pcall(function()
    -- Для Neovim 0.10+
    if vim.lsp.inlay_hint then
      -- Проверяем, поддерживает ли буфер inlay hints
      local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
      for _, client in ipairs(clients) do
        if client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(bufnr, true)
          print("Inlay hints enabled for buffer " .. bufnr)
          return
        end
      end
    -- Для старых версий Neovim
    elseif vim.lsp.buf.inlay_hint then
      vim.lsp.buf.inlay_hint(bufnr, true)
      print("Inlay hints enabled for buffer " .. bufnr)
    end
  end)
end

-- Функция для принудительного включения inlay hints во всех буферах
local function force_enable_inlay_hints()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      if ft == "go" then
        enable_inlay_hints(bufnr)
      end
    end
  end
end

-- Создаем команду для ручного включения подсказок типов
vim.api.nvim_create_user_command("EnableGoInlayHints", force_enable_inlay_hints, {})

-- Автоматически включаем inlay hints при загрузке Go файлов
vim.api.nvim_create_autocmd({"FileType"}, {
  pattern = {"go"},
  callback = function(args)
    vim.defer_fn(function()
      enable_inlay_hints(args.buf)
    end, 500)
  end,
  group = vim.api.nvim_create_augroup("GoInlayHintsEnable", { clear = true }),
})

-- Включаем inlay hints при подключении LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    
    if client.name == "gopls" and client.server_capabilities.inlayHintProvider then
      vim.defer_fn(function()
        enable_inlay_hints(args.buf)
      end, 500)
      
      -- Повторяем с большей задержкой для надежности
      vim.defer_fn(function()
        enable_inlay_hints(args.buf)
      end, 2000)
    end
  end,
  group = vim.api.nvim_create_augroup("GoInlayHintsLspAttach", { clear = true }),
})

-- Создаем таймер для периодической проверки и включения inlay hints
local inlay_hints_timer = vim.loop.new_timer()
inlay_hints_timer:start(3000, 5000, vim.schedule_wrap(function()
  force_enable_inlay_hints()
end))

-- Экспортируем функции
M.enable_inlay_hints = enable_inlay_hints
M.force_enable_inlay_hints = force_enable_inlay_hints

return M 