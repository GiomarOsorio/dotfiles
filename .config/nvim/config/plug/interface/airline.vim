"enable powerline fonts
let g:airline_powerline_fonts = 1

"set theme to airline
let g:airline_theme = 'minimalist'

" change how tags are displayed
let g:airline#extensions#tagbar#flags = 'f'

"Add the windows number in fron of the mode
function! WindowNumber(...)
    let builder = a:1
    let context = a:2
call builder.add_section('airline_b', '%{tabpagewinnr(tabpagenr())}')
    return 0
endfunction

call airline#add_statusline_func('WindowNumber')
call airline#add_inactive_statusline_func('WindowNumber') 
