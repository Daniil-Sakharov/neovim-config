return {
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			require('nvim-treesitter.configs').setup({
				-- Ограничиваем только необходимыми языками для Go-разработки
				ensure_installed = { 
					"go", "gomod", "gosum", -- Go-related
					"lua", -- Для конфигурации Neovim
					"json", "yaml", "toml", -- Основные форматы конфигурации
				},
				auto_install = false, -- Отключаем автоматическую установку для экономии ресурсов
				highlight = {
					enable = true,
					disable = function(lang, buf)
						local max_filesize = 100 * 1024 -- 100 KB
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true,
				},
				-- Отключаем ресурсоемкие функции
				incremental_selection = {
					enable = false, -- Отключаем для экономии ресурсов
				},
				-- Ограничиваем текстовые объекты только необходимыми
				textobjects = {
					select = {
						enable = true,
						lookahead = false, -- Отключаем предварительный просмотр
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							-- Оставляем только самые необходимые текстовые объекты
						},
					},
					-- Отключаем перемещение по объектам для экономии ресурсов
					move = {
						enable = false,
					},
					-- Отключаем обмен параметрами для экономии ресурсов
					swap = {
						enable = false,
					},
				},
				-- Включаем сворачивание кода на основе treesitter
				fold = {
					enable = true,
				},
			})

			-- Функция для проверки наличия парсера более безопасным способом
			local function is_parser_installed(lang)
				local parsers_dir = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser/"
				local parser_file = parsers_dir .. lang .. ".so"
				return vim.fn.filereadable(parser_file) == 1
			end
			
			-- Устанавливаем только критически важные парсеры
			local parsers = { "go" }
			for _, lang in ipairs(parsers) do
				if not is_parser_installed(lang) then
					vim.defer_fn(function()
						vim.cmd('TSInstall! ' .. lang)
					end, 1000) -- Отложенная установка для ускорения запуска
				end
			end

			-- Оптимизация производительности treesitter
			vim.api.nvim_create_autocmd("BufEnter", {
				callback = function(ev)
					-- Отключаем подсветку синтаксиса для больших файлов
					local max_filesize = 1024 * 1024 -- 1 MB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
					if ok and stats and stats.size > max_filesize then
						vim.cmd("TSBufDisable highlight")
					end
				end
			})
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
	}
}
