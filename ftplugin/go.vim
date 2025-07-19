" Специальное исправление запятой для Go файлов

" Удаляем все возможные маппинги запятой
silent! iunmap <buffer> ,
silent! iunmap ,

" Устанавливаем запятую напрямую через ASCII код
inoremap <buffer> <silent> , <Char-44>

" Создаем автокоманду для восстановления запятой при любых изменениях
augroup GoCommaFix
  autocmd!
  autocmd InsertEnter <buffer> silent! iunmap <buffer> , | inoremap <buffer> <silent> , <Char-44>
augroup END 

" Добавляем маппинг для запуска Go кода в отдельном терминале
function! RunGoCode()
  " Сохраняем текущий файл
  write
  " Получаем полный путь к текущему файлу
  let l:file_path = expand('%:p')
  " Открываем терминал в горизонтальном сплите и запускаем код
  botright 10new
  execute 'terminal go run ' . shellescape(l:file_path)
  " Фокусируемся на терминале и переходим в режим вставки
  startinsert
endfunction

" Маппинг leader+gr для запуска Go кода
nnoremap <buffer> <leader>gr :call RunGoCode()<CR>

" Принудительно включаем inlay hints для текущего буфера
if has('nvim-0.10')
  " Для Neovim 0.10+
  lua vim.defer_fn(function() pcall(function() vim.lsp.inlay_hint.enable(0, true) end) end, 1000)
else
  " Для старых версий
  lua vim.defer_fn(function() pcall(function() if vim.lsp.buf.inlay_hint then vim.lsp.buf.inlay_hint(0, true) end end) end, 1000)
endif

" Добавляем команду для включения inlay hints
command! -buffer GoEnableInlayHints lua vim.defer_fn(function() pcall(function() if vim.lsp.inlay_hint then vim.lsp.inlay_hint.enable(0, true) elseif vim.lsp.buf.inlay_hint then vim.lsp.buf.inlay_hint(0, true) end end) end, 500)

" Автоматически включаем inlay hints при открытии файла
augroup GoInlayHintsBuffer
  autocmd!
  autocmd BufEnter <buffer> GoEnableInlayHints
augroup END 