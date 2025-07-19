-- Этот файл загружается после всех плагинов и принудительно включает inlay hints для Go файлов

-- Функция для включения inlay hints во всех Go буферах
local function enable_go_inlay_hints()
  -- Проходим по всем буферам
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      -- Проверяем, что это Go файл
      local ft = vim.bo[bufnr].filetype
      if ft == "go" then
        -- Пробуем включить inlay hints разными способами
        pcall(function()
          -- Для Neovim 0.10+
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(bufnr, true)
          -- Для старых версий Neovim
          elseif vim.lsp.buf.inlay_hint then
            vim.lsp.buf.inlay_hint(bufnr, true)
          end
        end)
      end
    end
  end
end

-- Запускаем с задержкой после загрузки Neovim
vim.defer_fn(function()
  enable_go_inlay_hints()
  
  -- Создаем автокоманду для включения inlay hints при открытии Go файлов
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function(args)
      vim.defer_fn(function()
        pcall(function()
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(args.buf, true)
          elseif vim.lsp.buf.inlay_hint then
            vim.lsp.buf.inlay_hint(args.buf, true)
          end
        end)
      end, 1000)
    end,
    group = vim.api.nvim_create_augroup("ForceGoInlayHints", { clear = true })
  })
  
  -- Создаем автокоманду для включения inlay hints при подключении LSP
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end
      
      local ft = vim.bo[args.buf].filetype
      if ft == "go" and client.name == "gopls" then
        vim.defer_fn(function()
          pcall(function()
            if vim.lsp.inlay_hint then
              vim.lsp.inlay_hint.enable(args.buf, true)
            elseif vim.lsp.buf.inlay_hint then
              vim.lsp.buf.inlay_hint(args.buf, true)
            end
          end)
        end, 500)
      end
    end,
    group = vim.api.nvim_create_augroup("ForceLspInlayHints", { clear = true })
  })
  
  -- Создаем команду для ручного включения inlay hints
  vim.api.nvim_create_user_command("ForceGoInlayHints", enable_go_inlay_hints, {})
  
  -- Создаем таймер для периодического включения inlay hints
  local timer = vim.loop.new_timer()
  timer:start(5000, 10000, vim.schedule_wrap(enable_go_inlay_hints))
  
end, 2000) -- Задержка 2 секунды после загрузки Neovim 