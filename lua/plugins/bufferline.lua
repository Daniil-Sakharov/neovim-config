return {
	{
		'akinsho/bufferline.nvim',
		version = "*",
		dependencies = 'nvim-tree/nvim-web-devicons',
		config = function()
			local bufferline = require("bufferline")
			local colors = {
				bg = 'NONE',
				fg = '#c0caf5',
				selected_fg = '#7dcfff',
				selected_bg = 'NONE',
				visible_fg = '#bb9af7',
				visible_bg = 'NONE',
				error_fg = '#f7768e',
				warning_fg = '#e0af68',
				info_fg = '#7aa2f7',
				hint_fg = '#9ece6a',
			}
			bufferline.setup({
				options = {
					mode = "buffers",
					numbers = "ordinal",
					color_icons = true,
					indicator = {
						style = "icon",
						icon = "▎",
					},
					modified_icon = "●",
					close_icon = "",
					left_trunc_marker = "",
					right_trunc_marker = "",
					diagnostics = "nvim_lsp",
					diagnostics_indicator = function(count, level, diagnostics_dict, context)
						local s = ""
						for e, n in pairs(diagnostics_dict) do
							local sym = e == "error" and " " or (e == "warning" and " " or (e == "info" and " " or " "))
							s = s .. sym .. n .. " "
						end
						return s
					end,
					show_buffer_icons = true,
					show_buffer_close_icons = true,
					show_close_icon = true,
					show_tab_indicators = true,
					persist_buffer_sort = true,
					separator_style = "slant",
					always_show_bufferline = true,
				},
				highlights = {
					fill = { bg = colors.bg },
					background = { fg = colors.fg, bg = colors.bg },
					buffer_selected = { fg = colors.selected_fg, bg = colors.selected_bg, bold = true, italic = true },
					buffer_visible = { fg = colors.visible_fg, bg = colors.visible_bg },
					separator = { fg = colors.bg, bg = colors.bg },
					separator_selected = { fg = colors.bg, bg = colors.bg },
					separator_visible = { fg = colors.bg, bg = colors.bg },
					close_button = { fg = colors.fg, bg = colors.bg },
					close_button_selected = { fg = colors.selected_fg, bg = colors.selected_bg },
					close_button_visible = { fg = colors.visible_fg, bg = colors.visible_bg },
					modified = { fg = colors.warning_fg, bg = colors.bg },
					modified_selected = { fg = colors.warning_fg, bg = colors.selected_bg },
					modified_visible = { fg = colors.warning_fg, bg = colors.visible_bg },
					diagnostic = { fg = colors.error_fg, bg = colors.bg },
					diagnostic_selected = { fg = colors.error_fg, bg = colors.selected_bg },
					diagnostic_visible = { fg = colors.error_fg, bg = colors.visible_bg },
				},
			})
			vim.cmd [[hi BufferLineFill guibg=NONE ctermbg=NONE]]
			vim.cmd [[hi TabLineFill guibg=NONE ctermbg=NONE]]
		end,
	}
}
