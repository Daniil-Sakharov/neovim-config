return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local colors = {
        purple = '#bb9af7',
        cyan = '#7dcfff',
        bg = 'NONE',
        fg = '#c0caf5',
        black = '#1a1b26',
        blue = '#7aa2f7',
        orange = '#ff9e64',
        green = '#9ece6a',
        red = '#f7768e',
        yellow = '#e0af68',
      }
      local custom_theme = {
        normal = {
          a = { fg = colors.black, bg = colors.purple, gui = 'bold' },
          b = { fg = colors.cyan, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        insert = {
          a = { fg = colors.black, bg = colors.cyan, gui = 'bold' },
          b = { fg = colors.purple, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        visual = {
          a = { fg = colors.black, bg = colors.blue, gui = 'bold' },
          b = { fg = colors.cyan, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        replace = {
          a = { fg = colors.black, bg = colors.orange, gui = 'bold' },
          b = { fg = colors.cyan, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        command = {
          a = { fg = colors.black, bg = colors.yellow, gui = 'bold' },
          b = { fg = colors.cyan, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        inactive = {
          a = { fg = colors.cyan, bg = colors.bg },
          b = { fg = colors.cyan, bg = colors.bg },
          c = { fg = colors.cyan, bg = colors.bg },
        },
      }
      require('lualine').setup {
        options = {
          theme = custom_theme,
          icons_enabled = true,
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          globalstatus = true,
          disabled_filetypes = {},
        },
        sections = {
          lualine_a = { { 'mode', icon = '', separator = { left = '' }, right_padding = 2 } },
          lualine_b = {
            { 'branch', icon = '' },
            { 'diff', symbols = { added = ' ', modified = ' ', removed = ' ' } },
            { 'diagnostics', sources = { 'nvim_lsp' }, symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' } },
          },
          lualine_c = {
            { 'filename', icon = '', file_status = true, path = 1 },
            { 'filesize', icon = '' },
            { function() return require('nvim-web-devicons').get_icon(vim.fn.expand('%:t'), vim.fn.expand('%:e')) or '' end, color = { fg = colors.cyan } },
          },
          lualine_x = {
            { 'encoding', icon = '' },
            { 'fileformat', icons_enabled = true, symbols = { unix = '', dos = '', mac = '' } },
            { 'filetype', icon_only = true },
          },
          lualine_y = {
            { 'progress', icon = '' },
            { 'searchcount', icon = '' },
            { 'selectioncount', icon = '' },
          },
          lualine_z = {
            { 'location', icon = '', separator = { right = '' }, left_padding = 2 },
            { function() return os.date('%H:%M') end, icon = '' },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { 'filename', icon = '' } },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        extensions = {},
      }
    end
  }
}

