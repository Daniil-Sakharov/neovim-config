" Этот файл загружается при каждом запуске Neovim
" Он принудительно устанавливает клавиши leader+e и leader+q

" Удаляем все возможные маппинги для leader+e и leader+q
silent! nunmap <buffer> <leader>e
silent! nunmap <buffer> <leader>q
silent! nunmap <leader>e
silent! nunmap <leader>q

" Устанавливаем новые маппинги глобально
nnoremap <silent> <leader>e :Neotree toggle<CR>
nnoremap <silent> <leader>q :bd<CR>

" Создаем автокоманду для восстановления клавиш при входе в любой буфер
augroup ForceKeysGlobal
  autocmd!
  autocmd BufEnter * silent! nunmap <buffer> <leader>e
  autocmd BufEnter * silent! nunmap <buffer> <leader>q
  autocmd BufEnter * nnoremap <buffer> <silent> <leader>e :Neotree toggle<CR>
  autocmd BufEnter * nnoremap <buffer> <silent> <leader>q :bd<CR>
augroup END

" Создаем автокоманду для восстановления клавиш при движении курсора
augroup ForceKeysCursor
  autocmd!
  autocmd CursorMoved * call ForceRestoreKeys()
  autocmd CursorMovedI * call ForceRestoreKeys()
augroup END

" Создаем автокоманду для восстановления клавиш при выходе из режима вставки
augroup ForceKeysInsert
  autocmd!
  autocmd InsertLeave * call ForceRestoreKeys()
augroup END

" Создаем функцию для ручного восстановления клавиш
function! ForceRestoreKeys()
  silent! nunmap <buffer> <leader>e
  silent! nunmap <buffer> <leader>q
  silent! nunmap <leader>e
  silent! nunmap <leader>q
  nnoremap <silent> <leader>e :Neotree toggle<CR>
  nnoremap <silent> <leader>q :bd<CR>
  nnoremap <buffer> <silent> <leader>e :Neotree toggle<CR>
  nnoremap <buffer> <silent> <leader>q :bd<CR>
endfunction

" Создаем команду для вызова функции
command! ForceKeys call ForceRestoreKeys()

" Создаем автокоманду для восстановления клавиш при входе в Go файлы
augroup ForceKeysGo
  autocmd!
  autocmd FileType go,gomod call ForceRestoreKeys()
augroup END 