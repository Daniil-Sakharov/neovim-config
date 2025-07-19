return {
	{
		"williamboman/mason.nvim",
		config = function()
			require('mason').setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗"
					},
					border = "rounded",
					keymaps = {
						toggle_package_expand = "<CR>",
						install_package = "i",
						update_package = "u",
						check_package_version = "c",
						update_all_packages = "U",
						check_outdated_packages = "C",
						uninstall_package = "X",
						cancel_installation = "<C-c>",
						apply_language_filter = "<C-f>",
					},
				}
			})
		end
	},
	{
		'williamboman/mason-lspconfig.nvim',
		config = function()
			require("mason-lspconfig").setup(
			{
				ensure_installed = { 
					-- Go ecosystem
					"gopls", -- Go language server
					"golangci_lint_ls", -- Go linter
					"sqlls", -- SQL
					"sqls", -- SQL
					-- Other languages
					"lua_ls", -- Lua
					"ts_ls", -- JavaScript/TypeScript
					"yamlls", -- YAML (for Docker and K8s)
					"dockerls", -- Docker
					"docker_compose_language_service", -- Docker Compose
					"buf_ls", -- Protocol Buffers
					"jsonls", -- JSON
					"taplo", -- TOML
					"marksman", -- Markdown
				},
				automatic_installation = true,
			})
		end
	},
	{
		-- Tools installation through Mason
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					-- Go tools
					"gofumpt", -- Stricter gofmt
					"goimports", -- Auto import organization
					"gomodifytags", -- Modify struct tags
					"impl", -- Generate interface implementations
					"delve", -- Go debugger
					"gotests", -- Generate Go tests
					"golangci-lint", -- Go linter
					-- SQL tools
					"sqlfluff", -- SQL linter
					"sqlfmt", -- SQL formatter
					-- Others
					"prettier", -- General purpose formatter
					"yamlfmt", -- YAML formatter
					"yamllint", -- YAML linter
				},
				auto_update = true,
				run_on_start = true,
			})
		end
	},
}
