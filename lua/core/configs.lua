-- Line Numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Mouse
vim.opt.mouse = "a"
vim.opt.mousefocus = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Indent Settings
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Other
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.termguicolors = true

-- Fillchars
vim.opt.fillchars = {
	vert = "│",
	fold = "⠀",
	eob = " ", -- suppress ~ at EndOfBuffer
	-- diff = "⣿", -- alternatives = ⣿ ░ ─ ╱
	msgsep = "‾",
	foldopen = "▾",
	foldsep = "│",
	foldclose = "▸",
}

-- Оптимизация производительности
vim.opt.lazyredraw = true                -- Не перерисовывать экран во время выполнения макросов
vim.opt.updatetime = 300                 -- Уменьшить время обновления (по умолчанию 4000ms)
vim.opt.timeoutlen = 500                 -- Время ожидания завершения комбинации клавиш
vim.opt.redrawtime = 1500                -- Максимальное время на перерисовку синтаксиса
vim.opt.ttimeoutlen = 10                 -- Время ожидания кодов клавиш
vim.opt.synmaxcol = 200                  -- Максимальная длина строки для подсветки синтаксиса
vim.opt.hidden = true                    -- Разрешить скрытые буферы
vim.opt.history = 100                    -- Ограничить историю команд
vim.g.cursorhold_updatetime = 100        -- Уменьшить задержку CursorHold
vim.opt.shortmess:append("c")            -- Избегать показа сообщений о завершении
vim.opt.completeopt = "menuone,noselect" -- Оптимизация автодополнения
vim.opt.swapfile = false                 -- Отключить swap файлы
vim.opt.backup = false                   -- Отключить резервные копии
vim.opt.writebackup = false              -- Отключить резервные копии при записи
vim.opt.undofile = true                  -- Включить постоянную отмену
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir" -- Папка для файлов отмены

-- Отключение предупреждений о устаревших функциях
local disabled_warnings = {
    "Defining diagnostic signs with :sign-define or sign_define() is deprecated",
    "Use vim.diagnostic.config({ signs = { ... } }) instead",
    "Invalid settings: setting option \"analyses\": the 'fieldalignment' analyzer was removed in gopls/v0.17.0",
    "instead, hover over struct fields to see size/offset information",
    "Invalid settings: setting option \"completion\": unexpected setting"
}

-- Перехват и фильтрация сообщений
vim.notify = (function(original)
    return function(msg, level, opts)
        -- Проверяем, содержит ли сообщение текст из списка отключенных предупреждений
        for _, warning in ipairs(disabled_warnings) do
            if msg:match(warning) then
                return -- Не показываем предупреждение
            end
        end
        -- Для всех остальных сообщений используем стандартную функцию уведомлений
        return original(msg, level, opts)
    end
end)(vim.notify)

-- Отключение некоторых встроенных плагинов Vim
local disabled_built_ins = {
    "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
    "gzip", "zip", "zipPlugin", "tar", "tarPlugin",
    "getscript", "getscriptPlugin", "vimball", "vimballPlugin",
    "2html_plugin", "logipat", "rrhelper", "spellfile_plugin", "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end

-- Автокоманды для оптимизации
local performance_augroup = vim.api.nvim_create_augroup("Performance", { clear = true })

-- Отключение относительной нумерации строк в режиме вставки и при потере фокуса
vim.api.nvim_create_autocmd({ "InsertEnter", "BufLeave", "FocusLost" }, {
    group = performance_augroup,
    callback = function()
        if vim.wo.number then
            vim.wo.relativenumber = false
        end
    end
})

-- Включение относительной нумерации строк в обычном режиме и при получении фокуса
vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "FocusGained" }, {
    group = performance_augroup,
    callback = function()
        if vim.wo.number then
            vim.wo.relativenumber = true
        end
    end
})

-- Уменьшение частоты проверки диагностики
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    group = performance_augroup,
    callback = function()
        -- Обновляем диагностику только когда курсор не двигается
        vim.diagnostic.show()
    end
})

-- Отложенная загрузка некоторых функций
vim.api.nvim_create_autocmd("VimEnter", {
    group = performance_augroup,
    callback = function()
        -- Отложить некоторые операции после запуска Neovim
        vim.defer_fn(function()
            vim.cmd("silent! e") -- Перезагрузить текущий буфер
        end, 100)
    end
})

-- Очистка неиспользуемых буферов
vim.api.nvim_create_autocmd("BufHidden", {
    group = performance_augroup,
    callback = function()
        -- Удаляем скрытые буферы, если они не изменены
        local buf = tonumber(vim.fn.expand("<abuf>"))
        if buf and vim.api.nvim_buf_is_valid(buf) and not vim.api.nvim_buf_get_option(buf, "modified") then
            vim.defer_fn(function()
                if vim.api.nvim_buf_is_valid(buf) and not vim.api.nvim_buf_get_option(buf, "modified") then
                    vim.api.nvim_buf_delete(buf, { force = false })
                end
            end, 1000)
        end
    end
})
