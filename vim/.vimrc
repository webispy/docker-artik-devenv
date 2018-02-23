set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'taglist.vim'
Plugin 'Trinity'
Plugin 'tpope/vim-fugitive'

" Interface
Plugin 'vim-airline/vim-airline'
Plugin 'airblade/vim-gitgutter'
Plugin 'mhinz/vim-startify'

" Syntax
Plugin 'pangloss/vim-javascript'
Plugin 'node.js'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'

" Colorscheme
Plugin 'wombat256.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

set shell=/bin/bash
set ts=4
set sw=4
set softtabstop=4

set autoindent
set cindent
set smartindent

set cursorline
set hlsearch
set t_Co=256
set laststatus=2

:silent! colorscheme wombat256mod

set cc=80
highlight ExtraWhitespace ctermbg=red guibg=red
:match ExtraWhitespace /\s\+$\| \+ze\t/

nmap <F8> :TrinityToggleAll<CR>
nmap <F2> :TlistToggle<CR>

" airline
let g:airline_powerline_fonts = 0

" markdown
let g:vim_markdown_folding_disabled = 1
