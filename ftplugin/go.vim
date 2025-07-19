" Специальная конфигурация для Go файлов

" Исправление проблем с запятой
silent! iunmap <buffer> ,
silent! iunmap ,
inoremap <buffer> <silent> , <Char-44>

" Автокоманда для восстановления запятой
augroup GoCommaFix
  autocmd!
  autocmd InsertEnter <buffer> silent! iunmap <buffer> , | inoremap <buffer> <silent> , <Char-44>
augroup END 

" Функция для запуска Go кода
function! RunGoCode()
  write
  let l:file_path = expand('%:p')
  botright 10new
  execute 'terminal go run ' . shellescape(l:file_path)
  startinsert
endfunction

nnoremap <buffer> <leader>gr :call RunGoCode()<CR>

" Функция для безопасного включения inlay hints
function! SafeEnableInlayHints()
  lua << EOF
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
      
      if ft ~= "go" then
        return
      end
      
      -- Проверяем наличие gopls клиента
      local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })
      if #clients == 0 then
        return
      end
      
      -- Включаем inlay hints с использованием современного API
      pcall(function()
        if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end)
    end, 500)
EOF
endfunction

" Функция для восстановления подсветки синтаксиса
function! RestoreGoSyntaxHighlighting()
  " Принудительно перезагружаем синтаксис
  syntax clear
  syntax on
  
  " Обновляем семантическую подсветку через LSP
  lua << EOF
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })
      
      for _, client in ipairs(clients) do
        -- Отключаем семантические токены если они мешают
        if client.server_capabilities.semanticTokensProvider then
          client.server_capabilities.semanticTokensProvider = nil
        end
        
        -- Принудительно обновляем подсветку
        vim.lsp.semantic_tokens.force_refresh(bufnr)
      end
    end, 100)
EOF
  
  echo "Go syntax highlighting restored"
endfunction

" Команды для управления
command! -buffer GoEnableInlayHints call SafeEnableInlayHints()
command! -buffer GoRestoreSyntax call RestoreGoSyntaxHighlighting()
command! -buffer GoFixHighlighting call RestoreGoSyntaxHighlighting() | call SafeEnableInlayHints()

" Автокоманды для автоматического включения функций
augroup GoBufferEnhancements
  autocmd!
  " Включаем inlay hints при входе в буфер
  autocmd BufEnter <buffer> call SafeEnableInlayHints()
  " Восстанавливаем подсветку при необходимости
  autocmd ColorScheme <buffer> call RestoreGoSyntaxHighlighting()
  " Включаем hints после выхода из режима вставки
  autocmd InsertLeave <buffer> call SafeEnableInlayHints()
augroup END

" Маппинги для быстрого доступа
nnoremap <buffer> <leader>gh :GoEnableInlayHints<CR>
nnoremap <buffer> <leader>gs :GoRestoreSyntax<CR>
nnoremap <buffer> <leader>gf :GoFixHighlighting<CR>

echo "Go ftplugin loaded with enhanced features" 