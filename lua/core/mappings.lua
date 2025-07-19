-- Leader
vim.g.mapleader = " "

-- Создаем функцию для более надежной установки клавиатурных сочетаний
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = true
  opts.noremap = true  -- Всегда используем noremap для предотвращения рекурсии
  
  -- Используем pcall для безопасного вызова
  local status_ok, err = pcall(vim.keymap.set, mode, lhs, rhs, opts)
  if not status_ok then
    vim.notify("Ошибка при установке маппинга: " .. lhs .. " -> " .. err, vim.log.levels.ERROR)
  end
end

-- Insert
map("i", "jj", "<Esc>")

-- Убедимся, что запятая работает правильно
-- Безопасно удаляем маппинг для запятой, если он существует
pcall(function() vim.keymap.del("i", ",") end)
-- Устанавливаем запятую через ASCII код для максимальной совместимости
vim.keymap.set("i", ",", "<Char-44>", { noremap = true, silent = true })

-- Buffers
map("n", "<leader>w", ":w<CR>")

-- Закрытие буфера (leader+q)
map("n", "<leader>q", ":bd<CR>", { desc = "Закрыть буфер" })

-- Выход из Neovim
map("n", "<leader>Q", ":q!<CR>", { desc = "Выйти из Neovim" })

-- Neo-tree (leader+e)
map("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Открыть/закрыть файловый менеджер" })

-- Альтернативная клавиша для Neo-tree
map("n", "<F2>", ":Neotree toggle<CR>", { desc = "Открыть/закрыть файловый менеджер (альтернатива)" })

-- Navigation
map("n", "<c-k>", ":wincmd k<CR>")
map("n", "<c-j>", ":wincmd j<CR>")
map("n", "<c-h>", ":wincmd h<CR>")
map("n", "<c-l>", ":wincmd l<CR>")

-- Line navigation
map("n", "H", "^")
map("n", "L", "$")

-- Splits
map("n", "|", ":vsplit<CR>")
map("n", "\\", ":split<CR>")

-- Tabs
map("n", "<Tab>", ":BufferLineCycleNext<CR>")
map("n", "<s-Tab>", ":BufferLineCyclePrev<CR>")
map("n", "<leader>x", ":BufferLinePickClose<CR>")
map("n", "<c-x>", ":BufferLineCloseOthers<CR>")

-- Neotest mappings
map("n", "<leader>tn", ":lua require('neotest').run.run()<CR>")
map("n", "<leader>tf", ":lua require('neotest').run.run(vim.fn.expand('%'))<CR>")
map("n", "<leader>ts", ":lua require('neotest').summary.toggle()<CR>")
map("n", "<leader>to", ":lua require('neotest').output.open()<CR>")

-- Функция для отключения определенных маппингов
local function unmap(mode, lhs)
  local status_ok, _ = pcall(vim.keymap.del, mode, lhs)
  if not status_ok then
    -- Тихо игнорируем ошибки, если маппинг не существует
  end
end

-- Функция для принудительного восстановления клавиш
local function force_restore_keys()
  -- Сначала удаляем все возможные маппинги
  unmap("n", "<leader>q")
  unmap("n", "<leader>e")
  unmap("n", "<leader>q", { buffer = true })
  unmap("n", "<leader>e", { buffer = true })
  
  -- Затем устанавливаем наши маппинги
  map("n", "<leader>q", ":bd<CR>", { desc = "Закрыть буфер" })
  map("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Открыть/закрыть файловый менеджер" })
  
  -- Устанавливаем также через vim.cmd для максимальной совместимости
  vim.cmd([[
    nnoremap <silent> <leader>e :Neotree toggle<CR>
    nnoremap <silent> <leader>q :bd<CR>
  ]])
end

-- Создаем автокоманду для восстановления клавиш после загрузки всех плагинов
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Небольшая задержка для уверенности, что все плагины загрузились
    vim.defer_fn(function()
      force_restore_keys()
    end, 100) -- 100 мс задержки
    
    -- Повторяем с большей задержкой для полной уверенности
    vim.defer_fn(function()
      force_restore_keys()
    end, 500) -- 500 мс задержки
  end,
  group = vim.api.nvim_create_augroup("RestoreKeymaps", { clear = true }),
  pattern = "*",
})

-- Создаем автокоманду для восстановления клавиш при смене буфера
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  callback = function()
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
        force_restore_keys()
      end
    end, 50)
  end,
  group = vim.api.nvim_create_augroup("KeymapsFixEnter", { clear = true }),
})

-- Функция для проверки работы клавиатурных сочетаний
function CheckKeyMappings()
  local normal_maps = vim.api.nvim_get_keymap('n')
  print("Проверка клавиатурных сочетаний...")
  
  -- Ищем наши ключевые маппинги
  local found_q = false
  local found_e = false
  
  for _, map in ipairs(normal_maps) do
    if map.lhs == vim.g.mapleader .. "q" then
      print("leader+q найден: " .. (map.rhs or "[функция]"))
      found_q = true
    end
    if map.lhs == vim.g.mapleader .. "e" then
      print("leader+e найден: " .. (map.rhs or "[функция]"))
      found_e = true
    end
  end
  
  if not found_q then
    print("ВНИМАНИЕ: leader+q не найден!")
  end
  if not found_e then
    print("ВНИМАНИЕ: leader+e не найден!")
  end
end

-- Экспортируем функцию для использования через команду
vim.api.nvim_create_user_command("CheckKeyMappings", CheckKeyMappings, {})

-- Создаем команду для быстрого исправления маппингов
vim.api.nvim_create_user_command("FixKeyMappings", function()
  force_restore_keys()
end, {})
