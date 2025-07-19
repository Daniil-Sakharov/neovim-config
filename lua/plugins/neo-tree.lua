return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none", fg = "none" })
		vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "none" })

		-- Настройка иконок для диагностики
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "", -- Иконка ошибки
					[vim.diagnostic.severity.WARN] = "", -- Иконка предупреждения
					[vim.diagnostic.severity.INFO] = "", -- Иконка информации
					[vim.diagnostic.severity.HINT] = "󰋗", -- Иконка подсказки
				},
			},
		})

		-- Настройка иконок для папок и файлов
		-- Вы можете изменить эти иконки и цвета на любые другие
		local icons = {
			folder = {
				closed = "", -- Иконка закрытой папки
				open = "", -- Иконка открытой папки
				empty = "", -- Иконка пустой папки
				expander_collapsed = "", -- Иконка свернутого элемента
				expander_expanded = "", -- Иконка развернутого элемента
			},
			file = {
				default = "*", -- Иконка файла по умолчанию
			},
			modified = {
				symbol = "[+]", -- Символ для измененных файлов
			},
			git = {
				-- Иконки для Git-статуса
				added = "✚",
				modified = "",
				deleted = "✖",
				renamed = "",
				untracked = "",
				ignored = "",
				unstaged = "󰄱",
				staged = "",
				conflict = "",
			},
		}

		-- Настройка цветов для иконок
		local colors = {
			folder = {
				closed = "#800080", -- Цвет для закрытой папки
				open = "#800080", -- Цвет для открытой папки
				empty = "#800080", -- Цвет для пустой папки
			},
			file = {
				default = "#abb2bf", -- Цвет для файла по умолчанию
			},
			git = {
				added = "#98c379",
				modified = "#e5c07b",
				deleted = "#e06c75",
				renamed = "#61afef",
				untracked = "#d19a66",
				ignored = "#5c6370",
				unstaged = "#e06c75",
				staged = "#98c379",
				conflict = "#e06c75",
			},
		}

		-- Создаем пользовательские хайлайты для иконок папок
		vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = colors.folder.closed })
		vim.api.nvim_set_hl(0, "NeoTreeDirectoryOpenIcon", { fg = colors.folder.open })
		vim.api.nvim_set_hl(0, "NeoTreeDirectoryEmptyIcon", { fg = colors.folder.empty })

		require("neo-tree").setup({
			close_if_last_window = false,
			enable_git_status = true,
			enable_diagnostics = true,
			default_component_configs = {
				container = {
					enable_character_fade = true
				},
				indent = {
					indent_size = 2,
					padding = 1,
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					highlight = "NeoTreeIndentMarker",
					with_expanders = true,
					expander_collapsed = icons.folder.expander_collapsed,
					expander_expanded = icons.folder.expander_expanded,
					expander_highlight = "NeoTreeExpander",
				},
				icon = {
					folder_closed = icons.folder.closed,
					folder_open = icons.folder.open,
					folder_empty = icons.folder.empty,
					default = icons.file.default,
					highlight = "NeoTreeFileIcon",
					folder_highlight = "NeoTreeDirectoryIcon", -- Используем наш хайлайт для папок
					folder_open_highlight = "NeoTreeDirectoryOpenIcon", -- Хайлайт для открытой папки
					folder_empty_highlight = "NeoTreeDirectoryEmptyIcon", -- Хайлайт для пустой папки
					use_web_devicons = true,               -- Использовать иконки из nvim-web-devicons для файлов
				},
				modified = {
					symbol = icons.modified.symbol,
					highlight = "NeoTreeModified",
				},
				name = {
					trailing_slash = false,
					use_git_status_colors = true,
					highlight = "NeoTreeFileName",
				},
				git_status = {
					symbols = icons.git,
					highlights = {
						added = "NeoTreeGitAdded",
						modified = "NeoTreeGitModified",
						deleted = "NeoTreeGitDeleted",
						renamed = "NeoTreeGitRenamed",
						untracked = "NeoTreeGitUntracked",
						ignored = "NeoTreeGitIgnored",
						unstaged = "NeoTreeGitUnstaged",
						staged = "NeoTreeGitStaged",
						conflict = "NeoTreeGitConflict",
					},
				},
			},
			window = {
				position = "left",
				width = 30,
				mapping_options = {
					noremap = true,
					nowait = true,
				},
				mappings = {
					["<space>"] = "none",
					["<cr>"] = "open",
					["l"] = "open",
					["h"] = "close_node",
					["q"] = "close_window",
				},
			},
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = false,
				},
				follow_current_file = {
					enabled = true,
					leave_dirs_open = true,
				},
				hijack_netrw_behavior = "open_default",
				use_libuv_file_watcher = true,
			},
			buffers = {
				follow_current_file = {
					enabled = true,
				},
				group_empty_dirs = false,
			},
			git_status = {
				window = {
					position = "float",
				},
			},
		})

		-- Создаем хайлайты для Git-статусов
		vim.api.nvim_set_hl(0, "NeoTreeGitAdded", { fg = colors.git.added })
		vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = colors.git.modified })
		vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = colors.git.deleted })
		vim.api.nvim_set_hl(0, "NeoTreeGitRenamed", { fg = colors.git.renamed })
		vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = colors.git.untracked })
		vim.api.nvim_set_hl(0, "NeoTreeGitIgnored", { fg = colors.git.ignored })
		vim.api.nvim_set_hl(0, "NeoTreeGitUnstaged", { fg = colors.git.unstaged })
		vim.api.nvim_set_hl(0, "NeoTreeGitStaged", { fg = colors.git.staged })
		vim.api.nvim_set_hl(0, "NeoTreeGitConflict", { fg = colors.git.conflict })

		-- Регистрируем команду для переключения neo-tree
		vim.api.nvim_create_user_command("NeoTreeToggle", function()
			vim.cmd("Neotree toggle")
		end, {})
	end,
}
