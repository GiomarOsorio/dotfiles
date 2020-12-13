" This a fork of the fisa vim configuration file, please check the next link:
" https://vim.fisadev.com/

" ============================================================================
set encoding=utf-8                                   
set guifont=GoMono\ Nerd\ Font\ Mono:h10
let using_neovim = has('nvim')                       
let using_vim = !using_neovim                        
                                                     
" ============================================================================
" Vim-plug initialization                            
" Avoid modifying this section, unless you are very sure of what you are doing

let vim_plug_just_installed = 0
if using_neovim
    let vim_plug_path = expand('~/.config/nvim/autoload/plug.vim')
else
    let vim_plug_path = expand('~/.vim/autoload/plug.vim')
endif
if !filereadable(vim_plug_path)
    echo "Installing Vim-plug..."
    echo ""
    if using_neovim
        silent !mkdir -p ~/.config/nvim/autoload
        silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        silent !mkdir -p ~/.vim/autoload
        silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    endif
    let vim_plug_just_installed = 1
endif

" manually load vim-plug the first time
if vim_plug_just_installed
    :execute 'source '.fnameescape(vim_plug_path)
endif

" Obscure hacks done, you can now modify the rest of the config down below 
" as you wish :)
" IMPORTANT: some things in the config are vim or neovim specific. It's easy 
" to spot, they are inside `if using_vim` or `if using_neovim` blocks.

" ============================================================================

" ============================================================================
" Active plugins
" You can disable or add new ones here:

" this needs to be here, so vim-plug knows we are declaring the plugins we
" want to use
if using_neovim
    call plug#begin("~/.config/nvim/plugged")
else
    call plug#begin("~/.vim/plugged")
endif

source $HOME/.config/nvim/config/pluggins.vim
" Now the actual plugins:
" Retro groove color scheme for Vim
Plug 'morhetz/gruvbox'
" Intellisense engine for Vim8 & Neovim, full languague server protocol
" support as VSCode
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" A tree explorer plugin for vim
Plug 'scrooloose/nerdtree'
" Adds file type icons to Vim plugins
Plug 'ryanoasis/vim-devicons'
" Lean & mean status/tabline for vim that's light as air
Plug 'vim-airline/vim-airline'
" A collection of themes for vim-airline
Plug 'vim-airline/vim-airline-themes'
" Plugin that displays tags in a window, ordered by scope
Plug 'majutsushi/tagbar'

" Tell vim-plug we finished declaring plugins, so it can load them
call plug#end()

" ============================================================================
" Install plugins the first time vim runs

if vim_plug_just_installed
    echo "Installing Bundles, please ignore key map error messages"
    :PlugInstall
endif 
