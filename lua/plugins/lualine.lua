return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- Кастомная пурпурно-голубая цветовая схема
      local colors = {
        -- Основные цвета
        bg = '#1a1a1a',
        fg = '#ffffff',
        -- Пурпурные оттенки
        purple = '#bb9af7',
        purple_dark = '#9d7cd8',
        purple_light = '#c3a6fd',
        -- Голубые оттенки  
        cyan = '#7dcfff',
        cyan_dark = '#449dab',
        cyan_light = '#89ddff',
        blue = '#7aa2f7',
        blue_dark = '#565f89',
        -- Дополнительные цвета
        green = '#9ece6a',
        yellow = '#e0af68',
        orange = '#ff9e64',
        red = '#f7768e',
        pink = '#ff007c',
        -- Серые оттенки
        grey = '#414868',
        grey_dark = '#24283b',
        grey_light = '#a9b1d6',
        black = '#15161e',
        white = '#c0caf5',
      }

      -- Красивая тема с градиентными переходами
      local custom_theme = {
        normal = {
          a = { fg = colors.black, bg = colors.purple, gui = 'bold' },
          b = { fg = colors.white, bg = colors.grey },
          c = { fg = colors.grey_light, bg = 'NONE' },
          x = { fg = colors.grey_light, bg = 'NONE' },
          y = { fg = colors.white, bg = colors.grey },
          z = { fg = colors.black, bg = colors.cyan, gui = 'bold' },
        },
        insert = {
          a = { fg = colors.black, bg = colors.cyan, gui = 'bold' },
          b = { fg = colors.white, bg = colors.blue_dark },
          z = { fg = colors.black, bg = colors.blue, gui = 'bold' },
        },
        visual = {
          a = { fg = colors.black, bg = colors.orange, gui = 'bold' },
          b = { fg = colors.white, bg = colors.grey },
          z = { fg = colors.black, bg = colors.yellow, gui = 'bold' },
        },
        replace = {
          a = { fg = colors.black, bg = colors.red, gui = 'bold' },
          b = { fg = colors.white, bg = colors.grey },
          z = { fg = colors.black, bg = colors.pink, gui = 'bold' },
        },
        command = {
          a = { fg = colors.black, bg = colors.green, gui = 'bold' },
          b = { fg = colors.white, bg = colors.grey },
          z = { fg = colors.black, bg = colors.cyan_light, gui = 'bold' },
        },
        inactive = {
          a = { fg = colors.grey_light, bg = colors.grey_dark },
          b = { fg = colors.grey_light, bg = colors.grey_dark },
          c = { fg = colors.grey, bg = 'NONE' },
        },
      }

      -- Кастомные компоненты с иконками
      local function lsp_status()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return "󰅤 No LSP"
        end
        
        local client_names = {}
        for _, client in ipairs(clients) do
          table.insert(client_names, client.name)
        end
        return "󰒋 " .. table.concat(client_names, ", ")
      end

      local function diagnostics_count()
        local diagnostics = vim.diagnostic.get(0)
        local counts = { error = 0, warn = 0, info = 0, hint = 0 }
        
        for _, diag in ipairs(diagnostics) do
          if diag.severity == 1 then counts.error = counts.error + 1
          elseif diag.severity == 2 then counts.warn = counts.warn + 1  
          elseif diag.severity == 3 then counts.info = counts.info + 1
          elseif diag.severity == 4 then counts.hint = counts.hint + 1 end
        end
        
        local result = {}
        if counts.error > 0 then table.insert(result, " " .. counts.error) end
        if counts.warn > 0 then table.insert(result, " " .. counts.warn) end
        if counts.info > 0 then table.insert(result, " " .. counts.info) end
        if counts.hint > 0 then table.insert(result, "󰌵 " .. counts.hint) end
        
        return #result > 0 and table.concat(result, " ") or ""
      end

      local function git_diff()
        local diff = vim.b.gitsigns_status_dict
        if not diff then return "" end
        
        local result = {}
        if diff.added and diff.added > 0 then
          table.insert(result, " " .. diff.added)
        end
        if diff.changed and diff.changed > 0 then
          table.insert(result, " " .. diff.changed)
        end
        if diff.removed and diff.removed > 0 then
          table.insert(result, " " .. diff.removed)
        end
        
        return table.concat(result, " ")
      end

      local function file_size()
        local size = vim.fn.getfsize(vim.fn.expand('%:p'))
        if size <= 0 then return "" end
        
        local units = {"B", "KB", "MB", "GB"}
        local unit_index = 1
        
        while size > 1024 and unit_index < #units do
          size = size / 1024
          unit_index = unit_index + 1
        end
        
        return string.format("%.1f%s", size, units[unit_index])
      end

      local function macro_recording()
        local recording = vim.fn.reg_recording()
        if recording ~= "" then
          return "󰑋 @" .. recording
        end
        return ""
      end

      local function search_count()
        if vim.v.hlsearch == 0 then return "" end
        local ok, result = pcall(vim.fn.searchcount, { maxcount = 999 })
        if not ok or result.total == 0 then return "" end
        return string.format(" [%d/%d]", result.current, result.total)
      end

      local function buffer_info()
        local bufnr = vim.api.nvim_get_current_buf()
        local total_bufs = #vim.api.nvim_list_bufs()
        return string.format("󰈚 %d/%d", bufnr, total_bufs)
      end

      -- Конфигурация lualine
      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = custom_theme,
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = true,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = {
            {
              'mode',
              separator = { left = '' },
              right_padding = 2,
              fmt = function(str)
                local mode_icons = {
                  ['NORMAL'] = '󰋘 NORMAL',
                  ['INSERT'] = '󰝰 INSERT', 
                  ['VISUAL'] = '󰈈 VISUAL',
                  ['V-LINE'] = '󰈈 V-LINE',
                  ['V-BLOCK'] = '󰅴 V-BLOCK',
                  ['REPLACE'] = '󰛔 REPLACE',
                  ['COMMAND'] = '󰘳 COMMAND',
                  ['TERMINAL'] = ' TERMINAL',
                }
                return mode_icons[str] or str
              end
            }
          },
          lualine_b = {
            {
              'branch',
              icon = '',
              color = { fg = colors.purple_light, gui = 'bold' },
            },
            {
              git_diff,
              color = { fg = colors.cyan },
            },
          },
          lualine_c = {
            {
              'filename',
              file_status = true,
              newfile_status = false,
              path = 1, -- Относительный путь
              symbols = {
                modified = '󰏫',
                readonly = '󰌾',
                unnamed = '󰡯',
                newfile = '󰎔',
              },
              color = { fg = colors.white, gui = 'bold' },
            },
            {
              diagnostics_count,
              color = { fg = colors.red },
            },
            {
              search_count,
              color = { fg = colors.yellow },
            },
            {
              macro_recording,
              color = { fg = colors.orange, gui = 'bold' },
            },
          },
          lualine_x = {
            {
              lsp_status,
              color = { fg = colors.cyan_light },
            },
            {
              'encoding',
              fmt = string.upper,
              color = { fg = colors.grey_light },
            },
            {
              'fileformat',
              symbols = {
                unix = '󰌽',
                dos = '󰍲',
                mac = '󰘳',
              },
              color = { fg = colors.grey_light },
            },
          },
          lualine_y = {
            {
              'filetype',
              colored = true,
              icon_only = false,
              icon = { align = 'right' },
              color = { fg = colors.purple_light, gui = 'bold' },
            },
            {
              file_size,
              color = { fg = colors.cyan },
            },
            {
              'progress',
              color = { fg = colors.white },
            },
          },
          lualine_z = {
            {
              buffer_info,
              color = { fg = colors.black, bg = colors.purple_light },
            },
            {
              'location',
              separator = { right = '' },
              left_padding = 2,
              fmt = function(str)
                return '󰍋 ' .. str
              end
            },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              'filename',
              color = { fg = colors.grey },
            }
          },
          lualine_x = {
            {
              'location',
              color = { fg = colors.grey },
            }
          },
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {
          'neo-tree',
          'lazy',
          'mason',
          'trouble',
          'quickfix',
        }
      })

      -- Обновляем статус при изменениях
      vim.api.nvim_create_autocmd({'DiagnosticChanged', 'LspAttach', 'LspDetach'}, {
        callback = function()
          require('lualine').refresh()
        end,
      })
    end
  }
}

