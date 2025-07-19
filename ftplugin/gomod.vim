" Этот файл загружается автоматически при открытии gomod файлов
" Он имеет более высокий приоритет, чем глобальные настройки

" Удаляем все возможные маппинги для leader+e и leader+q
silent! nunmap <buffer> <leader>e
silent! nunmap <buffer> <leader>q
silent! nunmap <leader>e
silent! nunmap <leader>q

" Устанавливаем новые маппинги для текущего буфера
nnoremap <buffer> <silent> <leader>e :Neotree toggle<CR>
nnoremap <buffer> <silent> <leader>q :bd<CR>

" Устанавливаем глобальные маппинги для уверенности
nnoremap <silent> <leader>e :Neotree toggle<CR>
nnoremap <silent> <leader>q :bd<CR>

" Создаем автокоманду для повторной установки маппингов при входе в буфер
augroup GoModKeysForce
  autocmd!
  autocmd BufEnter <buffer> silent! nunmap <buffer> <leader>e
  autocmd BufEnter <buffer> silent! nunmap <buffer> <leader>q
  autocmd BufEnter <buffer> nnoremap <buffer> <silent> <leader>e :Neotree toggle<CR>
  autocmd BufEnter <buffer> nnoremap <buffer> <silent> <leader>q :bd<CR>
augroup END

" Убираем уведомление для тихой работы 