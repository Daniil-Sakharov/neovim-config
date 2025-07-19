return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local colors = {
        blue   = '#80a0ff',
        cyan   = '#79dac8',
        black  = '#080808',
        white  = '#c6c6c6',
        red    = '#ff5189',
        violet = '#d183e8',
        grey   = '#303030',
      }

      local bubbles_theme = {
        normal = {
          a = { fg = colors.black, bg = colors.violet },
          b = { fg = colors.white, bg = colors.grey },
          c = { fg = colors.white, bg = 'NONE' }, -- Прозрачная центральная часть
        },

        insert = {
          a = { fg = colors.black, bg = colors.blue },
          c = { fg = colors.white, bg = 'NONE' }, -- Для insert тоже
        },
        visual = {
          a = { fg = colors.black, bg = colors.cyan },
          c = { fg = colors.white, bg = 'NONE' },
        },
        replace = {
          a = { fg = colors.black, bg = colors.red },
          c = { fg = colors.white, bg = 'NONE' },
        },

        inactive = {
          a = { fg = colors.white, bg = colors.black },
          b = { fg = colors.white, bg = colors.black },
          c = { fg = colors.white, bg = 'NONE' },
        },
      }

      require('lualine').setup({
        options = {
          globalstatus = true,
          theme = bubbles_theme,
          component_separators = '',
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = {
            { 'mode', separator = { left = '' }, right_padding = 2 }
          },
          lualine_b = { 'filename', 'branch' },
          lualine_c = {
            '%=', -- центр выравнивается
          },
          lualine_x = {},
          lualine_y = { 'filetype', 'progress' },
          lualine_z = {
            { 'location', separator = { right = '' }, left_padding = 2 },
          },
        },
        inactive_sections = {
          lualine_a = { 'filename' },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { 'location' },
        },
        tabline = {},
        extensions = {},
      })
    end
  }
}

