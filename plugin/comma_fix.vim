" ПРЯМОЕ ИСПРАВЛЕНИЕ ЗАПЯТОЙ
" Этот файл использует прямой подход с сырыми кодами клавиш

" Полностью очищаем все маппинги для запятой
silent! iunmap ,
silent! iunmap <buffer> ,

" Устанавливаем запятую напрямую через ASCII код (44 - код запятой)
inoremap <silent> , <Char-44>

" Создаем автокоманду для постоянного исправления
augroup CommaDirectFix
  autocmd!
  " Исправляем при входе в режим вставки
  autocmd InsertEnter * silent! iunmap , | inoremap <silent> , <Char-44>
  " Исправляем при смене буфера
  autocmd BufEnter * silent! iunmap , | inoremap <silent> , <Char-44>
  " Исправляем при загрузке файла
  autocmd FileType * silent! iunmap , | inoremap <silent> , <Char-44>
augroup END

" Создаем команду для ручного исправления
command! FixCommaChar silent! iunmap , | inoremap <silent> , <Char-44> 