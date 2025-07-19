return {
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-cmdline" },
	{ "hrsh7th/cmp-vsnip" },
	{ "hrsh7th/vim-vsnip" },
	{ "hrsh7th/vim-vsnip-integ" },
	{ "rafamadriz/friendly-snippets" },
	-- Убираем ресурсоемкие источники
	-- { "lukas-reineke/cmp-rg" },        -- Поиск в проекте через ripgrep
	-- { "ray-x/cmp-treesitter" },        -- Автодополнение на основе treesitter
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			
			-- Сначала проверяем наличие vsnip
			local has_vsnip, _ = pcall(require, "vsnip")
			
			-- Настройка расширения сниппетов в зависимости от наличия плагинов
			local snippet_expand
			if has_vsnip then
				snippet_expand = function(args)
					vim.fn["vsnip#anonymous"](args.body)
				end
			else
				-- Запасной вариант - используем встроенные сниппеты
				snippet_expand = function(args)
					vim.snippet.expand(args.body)
				end
			end
			
			-- Переменная для отслеживания состояния автодополнения
			local is_cmp_enabled = true
			
			-- Функция для переключения автодополнения
			local function toggle_completion()
				is_cmp_enabled = not is_cmp_enabled
				if is_cmp_enabled then
					vim.notify("Автодополнение включено", vim.log.levels.INFO)
					cmp.setup.buffer({
						enabled = true
					})
				else
					vim.notify("Автодополнение отключено", vim.log.levels.INFO)
					cmp.setup.buffer({
						enabled = false
					})
				end
			end
			
			-- Регистрируем команду для переключения автодополнения
			vim.api.nvim_create_user_command("ToggleCompletion", toggle_completion, { desc = "Переключить автодополнение" })
			
			-- Добавляем горячую клавишу для переключения автодополнения
			vim.keymap.set("n", "<leader>tc", toggle_completion, { desc = "Переключить автодополнение" })
			
			-- Функция для проверки размера файла
			local function is_file_too_large(bufnr)
				local max_filesize = 100 * 1024 -- 100 KB
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr or 0))
				return ok and stats and stats.size > max_filesize
			end
			
			cmp.setup({
				snippet = {
					expand = snippet_expand,
				},
				window = {
					-- Упрощаем окно автодополнения
					completion = {
						winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
						scrollbar = false, -- Отключаем полосу прокрутки
					},
					documentation = {
						max_height = 15, -- Ограничиваем высоту окна документации
						max_width = 60,  -- Ограничиваем ширину окна документации
					},
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					-- Используем стрелки для навигации по списку и Tab для выбора
					["<Up>"] = cmp.mapping.select_prev_item(),
					["<Down>"] = cmp.mapping.select_next_item(),
					["<Tab>"] = cmp.mapping.confirm({ select = true }), -- Выбор элемента по Tab
					["<CR>"] = cmp.mapping.confirm({ select = false }), -- Подтверждение только явно выбранных элементов
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000, max_item_count = 10 }, -- Ограничиваем количество элементов
					{ name = "vsnip", priority = 900, max_item_count = 5 },      -- Ограничиваем количество элементов
					{ name = "path", priority = 800, max_item_count = 5 },       -- Ограничиваем количество элементов
				}, {
					{ name = "buffer", priority = 500, max_item_count = 5, keyword_length = 3 }, -- Минимум 3 символа для буфера
				}),
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol", -- Только символы для экономии ресурсов
						maxwidth = 30,   -- Уменьшаем максимальную ширину
						ellipsis_char = "...",
						-- Упрощаем меню
						menu = {
							buffer = "[B]",
							nvim_lsp = "[L]",
							vsnip = "[S]",
							path = "[P]",
						},
						before = function(_, vim_item)
							-- Ограничиваем длину имени элемента
							vim_item.abbr = string.sub(vim_item.abbr, 1, 20)
							return vim_item
						end
					})
				},
				-- Оптимизируем сортировку результатов автодополнения
				sorting = {
					comparators = {
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						cmp.config.compare.score,
						-- Убираем менее важные компараторы
						cmp.config.compare.kind,
						cmp.config.compare.length,
						cmp.config.compare.order,
					},
				},
				-- Отключаем экспериментальные функции
				experimental = {
					ghost_text = false, -- Отключаем "призрачный" текст для экономии ресурсов
				},
				enabled = function()
					-- Отключаем автодополнение для больших файлов
					if is_file_too_large() then
						return false
					end
					-- Возвращает текущее состояние автодополнения
					return is_cmp_enabled
				end,
				-- Ограничиваем частоту обновления
				performance = {
					debounce = 150,      -- Увеличиваем задержку перед обновлением
					throttle = 60,       -- Ограничиваем частоту обновления
					fetching_timeout = 200, -- Увеличиваем таймаут для получения данных
					async_budget = 1,    -- Ограничиваем асинхронный бюджет
					max_view_entries = 10 -- Ограничиваем количество элементов в представлении
				},
			})
			
			-- Настройка автодополнения для командной строки - упрощаем
			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = 'cmdline', max_item_count = 10 } -- Ограничиваем количество элементов
				}
			})
			
			-- Настройка автодополнения для поиска - упрощаем
			cmp.setup.cmdline('/', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = 'buffer', max_item_count = 5, keyword_length = 3 } -- Минимум 3 символа для буфера
				}
			})
			
			-- Настройка vsnip если он доступен
			if has_vsnip then
				-- Загрузка дополнительных сниппетов из friendly-snippets
				require("vsnip").filetype_extend("go", {"go"})
				
				-- Клавиши для навигации по сниппетам
				vim.cmd([[
				" Раскрытие сниппета или переход к следующему полю
				imap <expr> <C-j>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-j>'
				smap <expr> <C-j>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-j>'
				
				" Переход к предыдущему полю
				imap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
				smap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
				]])
			end
			
			-- Специальные настройки для Go - упрощаем
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {"go", "gomod", "gosum", "gowork"},
				callback = function()
					-- Проверяем размер файла
					if is_file_too_large(vim.api.nvim_get_current_buf()) then
						cmp.setup.buffer({ enabled = false })
						return
					end
					
					-- Повышаем приоритет LSP-автодополнения для Go
					cmp.setup.buffer({
						sources = cmp.config.sources({
							{ name = "nvim_lsp", priority = 1100, max_item_count = 10 }, -- Ограничиваем количество элементов
							{ name = "vsnip", priority = 900, max_item_count = 5 },
						}, {
							{ name = "buffer", priority = 500, max_item_count = 5, keyword_length = 3 }, -- Минимум 3 символа для буфера
						})
					})
				end
			})
		end,
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-vsnip",
			"hrsh7th/vim-vsnip",
			-- Убираем ресурсоемкие зависимости
			-- "lukas-reineke/cmp-rg",
			-- "ray-x/cmp-treesitter",
			"onsails/lspkind.nvim",
		},
	},
}
