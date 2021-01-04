" use 256 colors when possible
" Color Schemes Gruvbox
let g:gruvbox_contrast_dark = 'hard'
if has('gui_running') || using_neovim || (&term =~? 'mlterm\|xterm\|xterm-256\|screen-256')
    if !has('gui_running')
        let &t_Co = 256
    endif
    colorscheme gruvbox 
endif
" set background=black
