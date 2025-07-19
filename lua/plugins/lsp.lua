return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- For enhanced LSP configuration
			"b0o/SchemaStore.nvim",
			"folke/neodev.nvim",
		},
		config = function()
			-- Setup neodev for better lua development
			require("neodev").setup({
				-- Отключаем полную библиотеку для экономии ресурсов
				library = {
					plugins = false, -- Отключаем загрузку всех плагинов
					types = true,
				},
				setup_jsonls = false, -- Отключаем автоматическую настройку jsonls
				lspconfig = true,
				-- Отключаем тяжелые функции
				pathStrict = true,
			})

			local lspconfig = require("lspconfig")
			
			-- Ограничение использования памяти для gopls
			lspconfig.gopls.setup({
				settings = {
					gopls = {
						-- Включаем только критически важные функции
						completeUnimported = true,
						usePlaceholders = true,
						analyses = {
							unusedparams = true,
							shadow = false, -- Отключаем ресурсоемкий анализ теней
							nilness = false, -- Отключаем ресурсоемкий анализ nil
							unusedwrite = true,
							useany = false, -- Отключаем ресурсоемкий анализ
						},
						staticcheck = true,
						gofumpt = true,
						-- Ограничиваем линзы кода только необходимыми
						codelenses = {
							generate = true, -- go generate
							gc_details = false, -- Отключаем детали сборщика мусора
							test = true, -- Run tests
							tidy = true, -- Go mod tidy
							vendor = false, -- Отключаем для экономии ресурсов
							regenerate_cgo = false, -- Отключаем для экономии ресурсов
							upgrade_dependency = false, -- Отключаем для экономии ресурсов
						},
						-- Ограничиваем подсказки только необходимыми
						hints = {
							assignVariableTypes = false,
							compositeLiteralFields = false,
							compositeLiteralTypes = false,
							constantValues = false,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = false,
						},
						-- Ограничение использования памяти
						memoryMode = "DegradeClosed", -- Экономия памяти для закрытых файлов
						-- Ограничение использования CPU
						matcher = "CaseSensitive", -- Более быстрый алгоритм сопоставления
					},
				},
				-- Ограничиваем работу LSP для больших файлов
				before_init = function(params)
					local path = params.rootUri and vim.uri_to_fname(params.rootUri) or vim.fn.getcwd()
					local max_size = 1024 * 1024 -- 1MB
					if vim.fn.getfsize(path) > max_size then
						return false -- Отменяем инициализацию LSP для больших файлов
					end
				end,
			})

			-- SQL language server с ограниченными возможностями
			lspconfig.sqls.setup({
				on_attach = function(client)
					-- Отключаем форматирование на стороне сервера для экономии ресурсов
					client.server_capabilities.documentFormattingProvider = false
				end,
			})
			
			-- Оптимизированный Lua LSP
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" } -- Recognize vim global for neovim configs
						},
						workspace = {
							checkThirdParty = false,
							-- Ограничиваем библиотеку только необходимыми файлами
							library = {
								vim.fn.expand("$VIMRUNTIME/lua"),
								vim.fn.stdpath("config") .. "/lua"
							},
							-- Ограничиваем максимальный размер файлов
							maxPreload = 1000,
							preloadFileSize = 150,
						},
						completion = {
							callSnippet = "Replace",
							-- Отключаем автоматическое добавление скобок
							autoRequire = false,
						},
						-- Отключаем тяжелые функции
						telemetry = { enable = false },
						hint = { enable = false },
					}
				},
				-- Ограничиваем возможности для экономии ресурсов
				on_attach = function(client)
					client.server_capabilities.documentFormattingProvider = false
				end,
			})

			-- TypeScript/JavaScript с ограниченными возможностями
			lspconfig.ts_ls.setup({
				on_attach = function(client)
					-- Отключаем форматирование на стороне сервера для экономии ресурсов
					client.server_capabilities.documentFormattingProvider = false
				end,
			})

			-- YAML с ограниченными возможностями
			lspconfig.yamlls.setup({
				settings = {
					yaml = {
						-- Отключаем схемы для экономии ресурсов
						schemaStore = { enable = false },
						-- Отключаем проверку схем
						validate = false,
					},
				},
				on_attach = function(client)
					client.server_capabilities.documentFormattingProvider = false
				end,
			})

			-- Docker с ограниченными возможностями
			lspconfig.dockerls.setup({
				on_attach = function(client)
					client.server_capabilities.documentFormattingProvider = false
				end,
			})

			-- Protocol Buffers с ограниченными возможностями
			lspconfig.buf_ls.setup({
				on_attach = function(client)
					client.server_capabilities.documentFormattingProvider = false
				end,
			})

			-- Функция для проверки размера файла перед применением LSP
			local function is_file_too_large(bufnr)
				local max_filesize = 100 * 1024 -- 100 KB
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
				return ok and stats and stats.size > max_filesize
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Проверяем размер файла
					if is_file_too_large(ev.buf) then
						vim.defer_fn(function()
							vim.lsp.buf_detach_client(ev.buf, ev.data.client_id)
							vim.notify("LSP отключен для большого файла", vim.log.levels.INFO)
						end, 10)
						return
					end

					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					local opts = { buffer = ev.buf }
					
					-- Go to definition and references
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					
					-- Documentation and help
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					
					-- Type operations
					vim.keymap.set("n", "<Leader>D", vim.lsp.buf.type_definition, opts)
					
					-- Refactoring tools
					vim.keymap.set("n", "<Leader>lr", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename Symbol" })
					vim.keymap.set({ "n", "v" }, "<Leader>la", vim.lsp.buf.code_action, opts)
					
					-- Formatting
					vim.keymap.set("n", "<Leader>lf", function()
						vim.lsp.buf.format({ async = true })
					end, opts)
					
					-- Workspace management
					vim.keymap.set("n", "<Leader>lwa", vim.lsp.buf.add_workspace_folder, opts)
					vim.keymap.set("n", "<Leader>lwr", vim.lsp.buf.remove_workspace_folder, opts)
					vim.keymap.set("n", "<Leader>lwl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, opts)

					-- Go specific LSP commands
					if vim.bo[ev.buf].filetype == "go" then
						-- Import organization
						vim.keymap.set("n", "<leader>gi", function()
							vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
						end, opts)
						
						-- Go to type implementation
						vim.keymap.set("n", "<leader>gt", function() 
							vim.lsp.buf.code_action({ context = { only = { "source.typeImpl" } }, apply = true })
						end, opts)
					end
				end,
			})

			-- Nicer diagnostic icons - используем современный способ определения иконок
			local icons = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }

			-- Configure floating windows for diagnostics
			vim.diagnostic.config({
				-- Отключаем виртуальный текст для экономии ресурсов
				virtual_text = false,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = icons.Error,
						[vim.diagnostic.severity.WARN] = icons.Warn,
						[vim.diagnostic.severity.HINT] = icons.Hint,
						[vim.diagnostic.severity.INFO] = icons.Info,
					},
					numhl = {
						[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
						[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
						[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
						[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
					},
					texthl = {
						[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
						[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
						[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
						[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
					},
				},
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				float = {
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
				},
			})

			-- Add additional hover configuration
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
				vim.lsp.handlers.hover, {
					border = "rounded",
				}
			)

			-- Add additional signature help configuration
			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
				vim.lsp.handlers.signature_help, {
					border = "rounded",
				}
			)
		end,
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("trouble").setup({
				-- Better display of diagnostics
				position = "bottom",
				height = 10,
				width = 50,
				icons = true,
				mode = "workspace_diagnostics",
				fold_open = "",
				fold_closed = "",
				group = true,
				padding = true,
				action_keys = {
					close = "q",
					cancel = "<esc>",
					refresh = "r",
					jump = { "<cr>", "<tab>" },
					open_split = { "<c-x>" },
					open_vsplit = { "<c-v>" },
					open_tab = { "<c-t>" },
					jump_close = { "o" },
					toggle_mode = "m",
					toggle_preview = "P",
					hover = "K",
					preview = "p",
					close_folds = { "zM", "zm" },
					open_folds = { "zR", "zr" },
					toggle_fold = { "zA", "za" },
					previous = "k",
					next = "j",
				},
				-- Отключаем автоматическое открытие для экономии ресурсов
				auto_open = false,
				auto_close = false,
				auto_preview = false,
				auto_fold = true, -- Автоматически сворачиваем для экономии ресурсов
			})

			-- Keymaps for trouble
			vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>")
			vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>")
			vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>")
			vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>")
			vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>")
			vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>")
		end,
	},
}
