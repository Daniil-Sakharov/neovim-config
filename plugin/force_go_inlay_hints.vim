" Принудительное включение подсказок типов для Go файлов
" Этот файл использует VimScript для максимальной совместимости

" Функция для включения inlay hints
function! EnableGoInlayHints()
  " Сохраняем текущий буфер для восстановления позиции курсора
  let l:current_buf = bufnr('%')
  
  " Проходим по всем буферам
  for buf in getbufinfo({'buflisted':1})
    let l:bufnr = buf.bufnr
    " Проверяем, что это Go файл
    if getbufvar(l:bufnr, '&filetype') == 'go'
      " Пробуем включить inlay hints через Lua
      call luaeval('vim.defer_fn(function() pcall(function() if vim.lsp.inlay_hint then vim.lsp.inlay_hint.enable(_A, true) elseif vim.lsp.buf.inlay_hint then vim.lsp.buf.inlay_hint(_A, true) end end) end, 300)', l:bufnr)
    endif
  endfor
endfunction

" Команда для ручного включения подсказок типов
command! GoForceInlayHints call EnableGoInlayHints()

" Автоматически включаем подсказки при открытии Go файлов
augroup GoInlayHintsVim
  autocmd!
  autocmd FileType go call EnableGoInlayHints()
  " Включаем также при фокусировке, записи файла и выходе из режима вставки
  autocmd BufEnter,BufWritePost,InsertLeave *.go call EnableGoInlayHints()
  " Периодически пробуем включить подсказки (каждые 10 секунд)
  autocmd CursorHold,CursorHoldI *.go call EnableGoInlayHints()
augroup END

" Включаем при загрузке этого файла для уже открытых Go буферов
call EnableGoInlayHints()

" Создаем маппинг для быстрого включения подсказок типов
nnoremap <silent> <Leader>ht :GoForceInlayHints<CR>

" Принудительно перезагружаем gopls для текущего буфера
function! RestartGoplsForBuffer()
  " Перезапускаем gopls через LSP команды
  execute "LspRestart gopls"
  " Включаем подсказки типов с задержкой
  call timer_start(1000, {-> execute("GoForceInlayHints")})
  echo "gopls перезапущен и подсказки типов включены"
endfunction

" Команда для перезапуска gopls
command! GoLspRestart call RestartGoplsForBuffer()

" Маппинг для быстрого перезапуска gopls
nnoremap <silent> <Leader>lr :GoLspRestart<CR> 