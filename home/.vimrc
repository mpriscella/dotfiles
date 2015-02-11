" Create ~/.vim/autoload directory
if empty(glob("~/.vim/autoload"))
  silent !mkdir ~/.vim/autoload > /dev/null 2>&1
endif

" Load plug
if empty(glob("~/.vim/autoload/plug.vim"))
  execute '!curl -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

" Color Scheme
set background=dark
try
  colorscheme molokai
  let g:molokai_original = 1
  let g:rehash256 = 1
catch
endtry

" Column 80
if (exists('+colorcolumn'))
  set colorcolumn=80
  highlight ColorColumn ctermbg=9
endif

syntax enable
set nocompatible
filetype off
set novisualbell
set noerrorbells
set incsearch

" Splitting settings
set splitright
set splitbelow

" Folding Settings
set foldmethod=indent

call plug#begin('~/.vim/plugged')

" Syntax Bundles
Plug 'airblade/vim-gitgutter'
Plug 'derekwyatt/vim-scala'
Plug 'vim-ruby/vim-ruby', {'for': 'ruby'}
Plug 'chase/vim-ansible-yaml', {'for': 'yaml'}
Plug 'cakebaker/scss-syntax.vim', {'for': 'scss'}
Plug 'fatih/vim-go', {'for': 'go'}
Plug 'gorodinskiy/vim-coloresque', {'for': ['css', 'scss', 'html']}

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
Plug 'majutsushi/tagbar'
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
Plug 'Valloric/YouCompleteMe'
Plug 'kien/ctrlp.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
Plug 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Plug 'scrooloose/syntastic'
Plug 'marcweber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'Sirver/ultisnips'

Plug 'honza/vim-snippets'
let g:UltiSnipsExpandTrigger = "<c-j>"
let g:UltiSnipsEditSplit = "vertical"

Plug 'sjl/gundo.vim'
Plug 'mhinz/vim-startify'

Plug 'Raimondi/delimitMate'
let delimitMate_matchpairs = "(:),[:],{:}"

Plug 'ervandew/supertab'
Plug 'mattn/emmet-vim'

" Startify
Plug 'mhinz/vim-startify'
if filereadable(expand('todo.txt'))
  let g:startify_bookmarks = [ 'todo.txt' ]
endif

Plug 'gcmt/taboo.vim'
let g:taboo_tab_format = '[%N| %f%m]'

Plug 'duff/vim-scratch'
nmap <leader>s :Scratch<cr>

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

try
  set relativenumber
catch
  set number
endtry
set backspace=2
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

" Conque Term
Plug 'rosenfeld/conque-term'
:command Bash ConqueTerm bash

" Local Vimrc
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

call plug#end()
