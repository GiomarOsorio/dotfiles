" Vim settings and mappings
" You can edit them as you wish

" tabs and spaces handling
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" turn relative line numbers on
set rnu
set number

"set autoreload
set autoread

" remove ugly vertical lines on window division
set fillchars+=vert:\ 

" set leader key
let mapleader=","

" tab navigation mappings
map tt :tabnew<CR>
map <M-l> :tabn<CR>
imap <M-l> <ESC>:tabn<CR>
map <M-h> :tabp<CR>
imap <M-h> <ESC>:tabp<CR>

" window navigation mappings
nmap <C-l> <C-W><C-L>   
imap <C-l> <ESC><C-W><C-L>   
nmap <C-h> <C-W><C-H>   
imap <C-h> <ESC><C-W><C-H>   
nmap <C-k> <C-W><C-K>   
imap <C-k> <ESC><C-W><C-K>
nmap <C-j> <C-W><C-J>   
imap <C-j> <ESC><C-W><C-J>   

" when scrolling, keep cursor 3 lines away from screen border
set scrolloff=3

" integrated terminal
" open new split panes to right and below
"set splitright
set splitbelow
" turn terminal to normal mode with escape
tnoremap <Esc> <C-\><C-n>
" start terminal in insert mode
au BufEnter * if &buftype == 'terminal' | :startinsert | endif
" open terminal on ctrl+n
function! OpenTerminal()
  split term://zsh
  resize 5 
endfunction
nnoremap <c-t> :call OpenTerminal()<CR> 
