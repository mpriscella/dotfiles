" Color Scheme
syntax enable
set background=dark
colorscheme molokai
let g:molokai_original = 1
let g:rehash256 = 1

set nocompatible
filetype off
set novisualbell
set noerrorbells
set incsearch

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Vundle
Plugin 'gmarik/Vundle.vim'

" Syntax Bundles
Bundle 'derekwyatt/vim-scala'
Bundle 'vim-ruby/vim-ruby'
Bundle 'chase/vim-ansible-yaml'
Bundle 'cakebaker/scss-syntax.vim'
Bundle 'fatih/vim-go'
Plugin 'ap/vim-css-color'

" Syntax Mapping
" Drupal
au BufNewFile,BufRead *.module set filetype=php
au BufNewFile,BufRead *.inc set filetype=php
au BufNewFile,BufRead *.install set filetype=php
autocmd FileType php autocmd BufWritePre <buffer> :%s/\s\+$//e

" Markdown
au BufNewFile,BufRead *.markdown set textwidth=80 formatoptions+=t

" NERDTree
let mapleader = ","
nmap <leader>t :tabnew<cr>
nmap <leader>w :tabclose<cr>

" Tagbar
Bundle 'majutsushi/tagbar'
nmap gotag :TagbarToggle<cr>

" Tabs
nmap <leader>n :tabn<cr>
nmap <leader>p :tabp<cr>
nmap <leader>1 1gt<cr>
nmap <leader>2 2gt<cr>
nmap <leader>3 3gt<cr>
nmap <leader>4 4gt<cr>
nmap <leader>5 5gt<cr>
nmap <leader>6 6gt<cr>
nmap <leader>7 7gt<cr>
nmap <leader>8 8gt<cr>
nmap <leader>9 9gt<cr>

" Other Bundles
Bundle 'kien/ctrlp.vim'
Bundle 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Plugin 'scrooloose/syntastic'
Plugin 'marcweber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'honza/vim-snippets'
Plugin 'sjl/gundo.vim'
Plugin 'mhinz/vim-startify'

Plugin 'gcmt/taboo.vim'
let g:taboo_tab_format = '[%N| %f%m]'

Plugin 'duff/vim-scratch'
nmap <leader>s :Scratch<cr>

call vundle#end()
filetype plugin indent on

" Powerline Stuff
set guifont=Sauce\ Code\ Powerline:h15
let g:Powerline_symbols = 'fancy'
set encoding=utf-8
set t_Co=256
set fillchars+=stl:\ ,stlnc:\
set term=xterm-256color
set termencoding=utf-8
set laststatus=2

hi Visual ctermbg=LightGreen
" Cursor changes shape on INSERT
" iTerm2 - OSX

let tmux=$TMUX

if exists(tmux)
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

set number
set relativenumber
set backspace=indent,eol,start
set history=1000
set showcmd
set showmode
set gcr=a:blinkon0
set visualbell
set autoread
set hidden

set noswapfile
set nobackup
set nowb

set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set ignorecase

set list listchars=tab:\ \ ,trail:·

set nowrap
set linebreak

set foldmethod=indent
set foldnestmax=3
set nofoldenable

set wildmode=list:longest
set wildmenu
set wildignore=*.o,*.obj,*~
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*DS_Store*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

set scrolloff=8
set sidescrolloff=15
set sidescroll=1

:command NewView vsp | bufnr('%')

" Conque Term
Plugin 'rosenfeld/conque-term'
:command Bash ConqueTerm bash

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

