return {
  {
    "ray-x/go.nvim",
    dependencies = { 
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      -- Принудительно исправляем запятую перед настройкой go.nvim
      vim.cmd([[
        silent! iunmap ,
        inoremap <silent> , <Char-44>
      ]])
      
      -- Настраиваем gopls напрямую через lspconfig для максимального контроля
      local lspconfig = require("lspconfig")
      lspconfig.gopls.setup({
        cmd = {"gopls"},
        filetypes = {"go", "gomod", "gowork", "gotmpl"},
        root_dir = lspconfig.util.root_pattern("go.mod", ".git"),
        settings = {
          gopls = {
            -- Включаем все анализаторы
            analyses = {
              unusedparams = true,
              shadow = true,
              nilness = true,
              unusedwrite = true,
              useany = true,
              unusedvariable = true,
              structtag = true,
            },
            -- Включаем дополнительные функции
            staticcheck = true,
            gofumpt = true,
            usePlaceholders = true,
            completeUnimported = true,
            matcher = "fuzzy",
            symbolMatcher = "fuzzy",
            symbolStyle = "dynamic",
            -- Настройки inlay hints (встроенные подсказки типов)
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            -- Настраиваем линзы кода
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = false,
              run_govulncheck = false,
              test = true,
              tidy = true,
              upgrade_dependency = false,
              vendor = false,
            },
            -- Настройка для отображения документации
            hoverKind = "FullDocumentation",
            linkTarget = "pkg.go.dev",
            -- Дополнительные настройки
            experimentalPostfixCompletions = true,
            directoryFilters = {
              "-node_modules",
              "-vendor",
              "-tmp",
            },
            -- ВАЖНО: Отключаем семантические токены, которые могут мешать подсветке
            semanticTokens = false,
            
            completionBudget = "500ms",
            completionDocumentation = true,
            deepCompletion = true,
          },
        },
        on_attach = function(client, bufnr)
          -- Отключаем семантические токены для нормальной подсветки
          client.server_capabilities.semanticTokensProvider = nil
          
          -- Включаем inlay hints для текущего буфера
          if client.server_capabilities.inlayHintProvider then
            -- Используем безопасный вызов для включения inlay hints
            pcall(function()
              -- Для Neovim 0.10+
              if vim.lsp.inlay_hint then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
              -- Для старых версий Neovim
              elseif vim.lsp.buf.inlay_hint then
                vim.lsp.buf.inlay_hint(bufnr, true)
              end
            end)
            
            -- Принудительно включаем inlay hints с задержкой
            vim.defer_fn(function()
              pcall(function()
                if vim.lsp.inlay_hint then
                  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                elseif vim.lsp.buf.inlay_hint then
                  vim.lsp.buf.inlay_hint(bufnr, true)
                end
              end)
            end, 1000)
          end
          
          -- Добавляем команду для включения/выключения inlay hints
          vim.api.nvim_buf_create_user_command(bufnr, "ToggleInlayHints", function()
            pcall(function()
              -- Для Neovim 0.10+
              if vim.lsp.inlay_hint then
                local enabled = not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
                vim.lsp.inlay_hint.enable(enabled, { bufnr = bufnr })
                vim.notify("Inlay hints " .. (enabled and "enabled" or "disabled"), vim.log.levels.INFO)
              -- Для старых версий Neovim
              elseif vim.lsp.buf.inlay_hint then
                -- Переключаем состояние (нет API для проверки текущего состояния)
                vim.g.inlay_hints_visible = not vim.g.inlay_hints_visible
                vim.lsp.buf.inlay_hint(bufnr, vim.g.inlay_hints_visible)
                vim.notify("Inlay hints " .. (vim.g.inlay_hints_visible and "enabled" or "disabled"), vim.log.levels.INFO)
              end
            end)
          end, {})
          
          -- Добавляем маппинг для переключения inlay hints
          vim.keymap.set("n", "<leader>th", ":ToggleInlayHints<CR>", 
            { noremap = true, silent = true, buffer = bufnr, desc = "Toggle inlay hints" })
             
          -- Отключаем диагностические сообщения о неправильных именах функций
          vim.diagnostic.config({
            virtual_text = {
              format = function(diagnostic)
                -- Фильтруем сообщения о неправильных именах функций
                if diagnostic.message:match("func.*should be") then
                  return nil
                end
                return diagnostic.message
              end,
            },
          }, bufnr)
          
          -- Восстанавливаем стандартную подсветку синтаксиса
          vim.cmd([[
            syntax on
            hi! goField guifg=#d7d7ff ctermfg=189
            hi! goVariable guifg=#5fffff ctermfg=87
            hi! goFunctionCall guifg=#d7afff ctermfg=183
            hi! goFunction guifg=#00d7ff ctermfg=45
            hi! goType guifg=#00ffaf ctermfg=49
            hi! goVarDefs guifg=#5fffff ctermfg=87
          ]])
        end,
      })
      
      -- Настраиваем go.nvim с минимальными настройками, чтобы не конфликтовать с lspconfig
      require("go").setup({
        -- Enable auto import
        goimport = 'gopls',
        -- Enable auto formatting on save
        gofmt = 'gofumpt',
        -- Tag transform (when using GoAddTags)
        tag_transform = "camelcase",
        -- Template for test files
        test_template = 'testify',
        -- Test flags for GoTest
        test_runner = 'go',
        -- Show test result in real time
        test_show_result = true,
        -- Alternative VSCode style snippets (ultisnips is also available)
        snippet_engine = "vsnip",
        -- Lint configuration
        lsp_gofumpt = true,
        -- Enable diagnostics highlighting
        lsp_diag_hdlr = true,
        -- Enable documentation hover
        lsp_document_formatting = true,
        -- Disable inlay hints from go.nvim (используем нативные)
        lsp_inlay_hints = {
          enable = false,
        },
        -- Customize diagnostic signs
        diagnostic = {
          hdlr = true,
          underline = true,
          virtual_text = true
        },
        -- Configure null-ls integration
        dap_debug = true,
        dap_debug_gui = true,
        -- Отключаем встроенную конфигурацию LSP, так как мы настраиваем её напрямую
        lsp_cfg = false,
        -- Расширенные возможности для сниппетов
        luasnip = true,
        -- Настройка для работы с тегами структур
        tags_config = {
          tag_options = "json=omitempty",
          transform = "camelcase",
        },
        -- Настройка для работы с импортами
        gopls_cmd = nil,
        gopls_remote_auto = true,
        fillstruct = "gopls",
        -- Расширенные возможности для тестов
        test_flags = {
          "-v",
        },
        test_timeout = "30s",
        test_env = {},
        -- Расширенные возможности для отладки
        dap_debug_keymap = false,
        dap_debug_vt = true,
        dap_port = 38697,
        dap_timeout = 15,
        dap_retries = 20,
        -- ВАЖНО: Отключаем все встроенные маппинги плагина
        disable_mappings = true,
      })
       
      -- Принудительно включаем inlay hints после загрузки плагина
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        callback = function()
          vim.defer_fn(function()
            pcall(function()
              if vim.lsp.inlay_hint then
                vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
              elseif vim.lsp.buf.inlay_hint then
                vim.lsp.buf.inlay_hint(0, true)
              end
            end)
          end, 1000)
        end,
        group = vim.api.nvim_create_augroup("GoInlayHints", { clear = true })
      })
      
      -- Дополнительная команда для ручного включения подсказок типов
      vim.api.nvim_create_user_command("EnableGoTypeHints", function()
        pcall(function()
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
          elseif vim.lsp.buf.inlay_hint then
            vim.lsp.buf.inlay_hint(0, true)
          end
          vim.notify("Go type hints enabled", vim.log.levels.INFO)
        end)
      end, {})
      
      -- Setup auto commands for Go files
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          -- Auto format and imports on save
          require('go.format').goimport()
        end,
        group = vim.api.nvim_create_augroup("GoFormat", {})
      })

      -- Автоматическая инициализация go.mod при создании main.go в новой директории
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "main.go",
        callback = function()
          local file_path = vim.fn.expand("%:p")
          local dir_path = vim.fn.fnamemodify(file_path, ":h")
          
          -- Проверяем, существует ли go.mod в директории
          local go_mod_path = dir_path .. "/go.mod"
          local go_mod_exists = vim.fn.filereadable(go_mod_path) == 1
          
          if not go_mod_exists then
            -- Получаем имя директории для использования в качестве имени модуля
            local dir_name = vim.fn.fnamemodify(dir_path, ":t")
            
            -- Инициализируем go.mod
            local cmd = string.format("cd %s && go mod init %s", vim.fn.shellescape(dir_path), dir_name)
            local result = vim.fn.system(cmd)
            
            if vim.v.shell_error == 0 then
              vim.notify("go.mod успешно инициализирован для " .. dir_name, vim.log.levels.INFO)
              
              -- Автоматически добавляем зависимости, если они указаны в файле
              vim.fn.system(string.format("cd %s && go mod tidy", vim.fn.shellescape(dir_path)))
            else
              vim.notify("Ошибка при инициализации go.mod: " .. result, vim.log.levels.ERROR)
            end
          end
        end,
        group = vim.api.nvim_create_augroup("GoModInit", {})
      })

      -- Создаем команду для ручной инициализации go.mod
      vim.api.nvim_create_user_command("GoModInit", function()
        local file_path = vim.fn.expand("%:p")
        local dir_path = vim.fn.fnamemodify(file_path, ":h")
        
        -- Запрашиваем имя модуля у пользователя
        vim.ui.input({
          prompt = "Введите имя модуля (оставьте пустым для автоматического определения): ",
        }, function(module_name)
          if module_name == nil then
            return -- Пользователь отменил ввод
          end
          
          -- Если пользователь не ввел имя, используем имя директории
          if module_name == "" then
            module_name = vim.fn.fnamemodify(dir_path, ":t")
          end
          
          -- Инициализируем go.mod
          local cmd = string.format("cd %s && go mod init %s", vim.fn.shellescape(dir_path), module_name)
          local result = vim.fn.system(cmd)
          
          if vim.v.shell_error == 0 then
            vim.notify("go.mod успешно инициализирован для " .. module_name, vim.log.levels.INFO)
            
            -- Автоматически добавляем зависимости, если они указаны в файле
            vim.fn.system(string.format("cd %s && go mod tidy", vim.fn.shellescape(dir_path)))
          else
            vim.notify("Ошибка при инициализации go.mod: " .. result, vim.log.levels.ERROR)
          end
        end)
      end, {})

      -- Принудительно восстанавливаем клавиши leader+e и leader+q в Go файлах
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {"go", "gomod"},
        callback = function()
          -- Задержка для уверенности, что плагин go.nvim уже установил свои маппинги
          vim.defer_fn(function()
            -- Удаляем возможные конфликтующие маппинги
            pcall(vim.keymap.del, "n", "<leader>e", { buffer = true })
            pcall(vim.keymap.del, "n", "<leader>q", { buffer = true })
            
            -- Устанавливаем наши маппинги для текущего буфера
            vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true, silent = true, buffer = true })
            vim.keymap.set("n", "<leader>q", ":bd<CR>", { noremap = true, silent = true, buffer = true })
          end, 50) -- 50 мс задержки
        end,
        group = vim.api.nvim_create_augroup("GoKeymapsRestorePlugin", { clear = true })
      })
      
      -- Создаем команду для принудительного восстановления клавиш
      vim.api.nvim_create_user_command("RestoreGoKeys", function()
        -- Удаляем возможные конфликтующие маппинги
        pcall(vim.keymap.del, "n", "<leader>e", { buffer = true })
        pcall(vim.keymap.del, "n", "<leader>q", { buffer = true })
        
        -- Устанавливаем наши маппинги для текущего буфера
        vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true, silent = true, buffer = true })
        vim.keymap.set("n", "<leader>q", ":bd<CR>", { noremap = true, silent = true, buffer = true })
      end, {})

      -- Дополнительные горячие клавиши для Go
      -- Убедимся, что они не конфликтуют с основными клавишами
      local keymap = function(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.silent = true
        -- Удаляем параметр priority, который не поддерживается
        vim.keymap.set(mode, lhs, rhs, opts)
      end
      
      -- Go-специфичные клавиши
      keymap("n", "<leader>gr", function()
        -- Получаем текущий файл и директорию
        local file_path = vim.fn.expand("%:p")
        local dir_path = vim.fn.fnamemodify(file_path, ":h")
        
        -- Создаем новое окно терминала для запуска
        vim.cmd("vsplit")
        vim.cmd("terminal cd " .. vim.fn.shellescape(dir_path) .. " && go run " .. vim.fn.shellescape(file_path))
        
        -- Переключаемся в режим вставки для взаимодействия с терминалом
        vim.cmd("startinsert")
        
        -- Уведомление о запуске
        vim.notify("Запуск Go программы: " .. vim.fn.fnamemodify(file_path, ":t"), vim.log.levels.INFO)
      end, { desc = "Запустить программу Go в отдельном окне" })
      keymap("n", "<leader>gb", ":GoBuild<CR>", { desc = "Скомпилировать программу Go" })
      keymap("n", "<leader>gd", ":GoDebug<CR>", { desc = "Отладить программу Go" })
      keymap("n", "<leader>gat", ":GoAddTags<CR>", { desc = "Добавить теги структуры" })
      keymap("n", "<leader>grt", ":GoRmTags<CR>", { desc = "Удалить теги структуры" })
      keymap("n", "<leader>gfs", ":GoFillStruct<CR>", { desc = "Заполнить структуру нулевыми значениями" })
      keymap("n", "<leader>gem", ":GoIfErr<CR>", { desc = "Сгенерировать проверку if err != nil" })
      keymap("n", "<leader>gca", ":GoCoverage<CR>", { desc = "Показать покрытие тестами" })
      keymap("n", "<leader>gct", ":GoCoverageToggle<CR>", { desc = "Переключить отображение покрытия" })
      keymap("n", "<leader>git", ":GoImpl<CR>", { desc = "Сгенерировать реализацию интерфейса" })
      keymap("n", "<leader>gim", ":GoImport ", { desc = "Добавить импорт" })
      keymap("n", "<leader>gia", ":GoImportAll<CR>", { desc = "Импортировать все необходимые пакеты" })
      keymap("n", "<leader>gmi", ":GoModInit<CR>", { desc = "Инициализировать go.mod" })
      keymap("n", "<leader>gmt", ":!go mod tidy<CR>", { desc = "Выполнить go mod tidy" })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", 'gomod' },
    build = ':lua require("go.install").update_all_sync()'
  },
  
  -- Дополнительный плагин для работы с Go
  {
    "leoluz/nvim-dap-go",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      require('dap-go').setup {
        -- Расширенные настройки для отладки Go
        dap_configurations = {
          {
            type = "go",
            name = "Debug",
            request = "launch",
            program = "${file}"
          },
          {
            type = "go",
            name = "Debug Package",
            request = "launch",
            program = "${fileDirname}"
          },
          {
            type = "go",
            name = "Debug test",
            request = "launch",
            mode = "test",
            program = "${file}"
          },
          {
            type = "go",
            name = "Debug test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}"
          }
        },
        -- Настройка для автоматической установки delve
        delve = {
          initialize_timeout_sec = 20,
          port = "${port}",
        },
      }
      
      -- Горячие клавиши для отладки Go
      vim.keymap.set("n", "<leader>dt", function() require('dap-go').debug_test() end, { desc = "Debug go test" })
      vim.keymap.set("n", "<leader>dl", function() require('dap-go').debug_last() end, { desc = "Debug last go test" })
    end,
    ft = { "go", 'gomod' },
  }
} 