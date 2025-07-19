-- Этот файл загружается после всех плагинов и гарантирует работу клавиш
-- Файл автоматически восстанавливает клавиши leader+e и leader+q

-- Функция для безопасного удаления маппингов
local function safe_unmap(mode, lhs, opts)
  opts = opts or {}
  pcall(vim.keymap.del, mode, lhs, opts)
end

-- Функция для безопасной установки маппингов
local function safe_map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = true
  opts.noremap = true
  pcall(vim.keymap.set, mode, lhs, rhs, opts)
end

-- Функция для восстановления клавиш
local function restore_keys()
  -- Принудительно удаляем все возможные маппинги
  -- Сначала буферные
  safe_unmap("n", "<leader>e", { buffer = true })
  safe_unmap("n", "<leader>q", { buffer = true })
  
  -- Затем глобальные
  safe_unmap("n", "<leader>e")
  safe_unmap("n", "<leader>q")
  
  -- Устанавливаем наши глобальные маппинги
  vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { 
    desc = "Открыть/закрыть файловый менеджер", 
    silent = true, 
    noremap = true
  })
  
  vim.keymap.set("n", "<leader>q", ":bd<CR>", { 
    desc = "Закрыть буфер", 
    silent = true, 
    noremap = true
  })
  
  -- Устанавливаем также через vim.cmd для максимальной совместимости
  vim.cmd([[
    nnoremap <silent> <leader>e :Neotree toggle<CR>
    nnoremap <silent> <leader>q :bd<CR>
  ]])
end

-- Восстанавливаем клавиши при загрузке этого файла
restore_keys()

-- Создаем автокоманду для восстановления клавиш при входе в Go файлы
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"go", "gomod"},
  callback = function()
    -- Восстанавливаем клавиши немедленно
    restore_keys()
    
    -- И еще раз с небольшой задержкой для уверенности
    vim.defer_fn(function()
      restore_keys()
    end, 50)
  end,
  group = vim.api.nvim_create_augroup("KeymapsFix", { clear = true }),
})

-- Создаем автокоманду для восстановления клавиш при смене буфера
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  callback = function()
    restore_keys()
  end,
  group = vim.api.nvim_create_augroup("KeymapsFixBuffer", { clear = true }),
})

-- Создаем автокоманду для восстановления клавиш после загрузки плагинов
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Восстанавливаем клавиши немедленно
    restore_keys()
    
    -- И еще раз с задержкой для уверенности
    vim.defer_fn(function()
      restore_keys()
    end, 300)
  end,
  group = vim.api.nvim_create_augroup("KeymapsFixVimEnter", { clear = true }),
  once = true,
})

-- Создаем автокоманду для восстановления клавиш при движении курсора
vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
  callback = function()
    -- Используем счетчик, чтобы не восстанавливать клавиши слишком часто
    if not vim.g.cursor_moved_count then
      vim.g.cursor_moved_count = 0
    end
    
    vim.g.cursor_moved_count = vim.g.cursor_moved_count + 1
    
    -- Восстанавливаем клавиши каждые 10 движений курсора
    if vim.g.cursor_moved_count >= 10 then
      vim.g.cursor_moved_count = 0
      restore_keys()
    end
  end,
  group = vim.api.nvim_create_augroup("KeymapsFixCursor", { clear = true }),
})

-- Создаем автокоманду для восстановления клавиш при выходе из режима вставки
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    restore_keys()
  end,
  group = vim.api.nvim_create_augroup("KeymapsFixInsert", { clear = true }),
})

-- Создаем команду для ручного восстановления клавиш
vim.api.nvim_create_user_command("FixKeys", restore_keys, {
  desc = "Восстановить клавиши leader+e и leader+q"
})

-- Создаем автокоманду для восстановления клавиш каждые 5 секунд
local timer = vim.loop.new_timer()
if timer then
  timer:start(1000, 5000, vim.schedule_wrap(function()
    restore_keys()
  end))
end

-- Исправляем проблему с запятой в режиме вставки
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Удаляем все возможные маппинги для запятой
    pcall(vim.keymap.del, "i", ",")
    
    -- Устанавливаем запятую как обычный символ
    vim.keymap.set("i", ",", ",", { noremap = true, silent = true })
  end,
  group = vim.api.nvim_create_augroup("FixComma", { clear = true }),
  once = true,
})

-- Создаем автокоманду для восстановления запятой при входе в режим вставки
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    pcall(vim.keymap.del, "i", ",")
    vim.keymap.set("i", ",", ",", { noremap = true, silent = true })
  end,
  group = vim.api.nvim_create_augroup("FixCommaInsert", { clear = true }),
}) 