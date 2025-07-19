-- Скрипт для диагностики и исправления проблем с Go inlay hints и подсветкой
-- Запустите: :luafile fix_go_setup.lua

print("=== Диагностика Go LSP Setup ===")

-- Проверяем версию Neovim
local nvim_version = vim.version()
print(string.format("Neovim версия: %d.%d.%d", nvim_version.major, nvim_version.minor, nvim_version.patch))

-- Проверяем поддержку inlay hints
if vim.lsp.inlay_hint then
  print("✅ Inlay hints API доступен")
else
  print("❌ Inlay hints API недоступен (требуется Neovim 0.10+)")
end

-- Проверяем активные LSP клиенты
local clients = vim.lsp.get_clients()
print(string.format("Активных LSP клиентов: %d", #clients))

local gopls_found = false
for _, client in ipairs(clients) do
  print(string.format("  - %s (поддержка inlay hints: %s)", 
    client.name, 
    client.server_capabilities.inlayHintProvider and "Да" or "Нет"))
  if client.name == "gopls" then
    gopls_found = true
  end
end

if not gopls_found then
  print("⚠️  gopls клиент не найден")
end

-- Проверяем текущий буфер
local bufnr = vim.api.nvim_get_current_buf()
local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
print(string.format("Текущий тип файла: %s", ft))

if ft == "go" then
  print("✅ Это Go файл")
  
  -- Проверяем клиентов для текущего буфера
  local buf_clients = vim.lsp.get_clients({ bufnr = bufnr })
  print(string.format("LSP клиентов для этого буфера: %d", #buf_clients))
  
  for _, client in ipairs(buf_clients) do
    print(string.format("  - %s", client.name))
  end
  
  -- Проверяем статус inlay hints
  if vim.lsp.inlay_hint and vim.lsp.inlay_hint.is_enabled then
    local hints_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
    print(string.format("Inlay hints включены: %s", hints_enabled and "Да" or "Нет"))
  end
else
  print("ℹ️  Не Go файл, для тестирования откройте Go файл")
end

print("\n=== Выполнение исправлений ===")

-- Функция для безопасного включения inlay hints
local function safe_enable_hints()
  if ft ~= "go" then
    print("⚠️  Не Go файл, пропускаем")
    return
  end
  
  local go_clients = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })
  if #go_clients == 0 then
    print("⚠️  gopls не подключен к этому буферу")
    return
  end
  
  if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    print("✅ Inlay hints включены")
  else
    print("❌ Не удалось включить inlay hints")
  end
end

-- Функция для восстановления подсветки
local function restore_highlighting()
  -- Отключаем семантические токены для gopls
  for _, client in ipairs(vim.lsp.get_clients({ name = "gopls" })) do
    if client.server_capabilities.semanticTokensProvider then
      client.server_capabilities.semanticTokensProvider = nil
      print("✅ Семантические токены gopls отключены")
    end
  end
  
  -- Перезагружаем синтаксис
  vim.cmd("syntax clear")
  vim.cmd("syntax on")
  print("✅ Синтаксис перезагружен")
end

-- Выполняем исправления
restore_highlighting()
vim.defer_fn(safe_enable_hints, 1000)

print("\n=== Доступные команды ===")
print(":GoEnableInlayHints - включить inlay hints")
print(":GoCheckInlayHints - проверить статус")
print(":GoRestartLspHints - перезапустить gopls с hints")
print(":GoFixHighlighting - исправить подсветку и hints")
print("<leader>th - переключить inlay hints")
print("<leader>ih - включить inlay hints")
print("<leader>gf - исправить все проблемы")

print("\n✅ Диагностика завершена!")
print("Если проблемы остались, попробуйте:")
print("1. :GoRestartLspHints")
print("2. :LspRestart gopls")
print("3. Перезапустить Neovim")