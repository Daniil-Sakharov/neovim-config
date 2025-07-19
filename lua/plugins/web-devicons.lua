return {
	"nvim-tree/nvim-web-devicons",
	lazy = false, -- Важно загрузить сразу, чтобы иконки были доступны
	priority = 1000, -- Высокий приоритет загрузки
	config = function()
		require("nvim-web-devicons").setup({
			-- Включаем иконки по умолчанию
			default = true,
			-- Включаем строгое соответствие
			strict = true,
			-- Переопределяем иконки для различных типов файлов
			override = {
				-- Go файлы
				go = {
					icon = "",
					color = "#00ADD8",
					name = "Go",
				},
				["go.mod"] = {
					icon = "󰟓",
					color = "#00ADD8",
					name = "GoMod",
				},
				["go.sum"] = {
					icon = "󰊕",
					color = "#00ADD8",
					name = "GoSum",
				},
				["go.work"] = {
					icon = "",
					color = "#00ADD8",
					name = "GoWork",
				},

				-- Lua файлы
				lua = {
					icon = "",
					color = "#51A0CF",
					name = "Lua",
				},

				-- Конфигурационные файлы
				json = {
					icon = "",
					color = "#cbcb41",
					name = "Json",
				},
				yaml = {
					icon = "",
					color = "#6d8086",
					name = "Yaml",
				},
				yml = {
					icon = "",
					color = "#6d8086",
					name = "Yml",
				},
				toml = {
					icon = "",
					color = "#6d8086",
					name = "Toml",
				},

				-- Веб-разработка
				html = {
					icon = "",
					color = "#e34c26",
					name = "HTML",
				},
				css = {
					icon = "",
					color = "#563d7c",
					name = "CSS",
				},
				js = {
					icon = "",
					color = "#f1e05a",
					name = "JavaScript",
				},
				ts = {
					icon = "ﯤ",
					color = "#3178c6",
					name = "TypeScript",
				},

				-- Документация
				md = {
					icon = "",
					color = "#519aba",
					name = "Markdown",
				},

				-- Системные файлы
				["dockerfile"] = {
					icon = "",
					color = "#458ee6",
					name = "Dockerfile",
				},
				["makefile"] = {
					icon = "",
					color = "#6d8086",
					name = "Makefile",
				},
				sh = {
					icon = "",
					color = "#4d5a5e",
					name = "Shell",
				},

				-- Специальные файлы
				[".gitignore"] = {
					icon = "",
					color = "#f1502f",
					name = "GitIgnore",
				},
				["license"] = {
					icon = "",
					color = "#d0bf41",
					name = "License",
				},
				["readme.md"] = {
					icon = "",
					color = "#42a5f5",
					name = "Readme",
				},
			},
		})
	end,
}

