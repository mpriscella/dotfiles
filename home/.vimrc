set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

Plugin 'gmarik/Vundle.vim'

" Syntax Bundles
Bundle 'derekwyatt/vim-scala'
Bundle 'vim-ruby/vim-ruby'
Bundle 'plasticboy/vim-markdown'
Bundle 'chase/vim-ansible-yaml'
Bundle 'kien/ctrlp.vim'

" NERDTree
Plugin 'scrooloose/nerdtree'
let mapleader = ","
nmap <leader>b :NERDTreeToggle<cr>
nmap <leader>t :tabnew<cr>
nmap <leader>w :tabclose<cr>

" Tabs "
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

Bundle 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'git://git.wincent.com/command-t.git'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}

call vundle#end()
filetype plugin indent on

" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins

" Powerline Stuff
set guifont=Sauce\ Code\ Powerline:h15
let g:Powerline_symbols = 'fancy'
set encoding=utf-8
set t_Co=256
set fillchars+=stl:\ ,stlnc:\
set term=xterm-256color
set termencoding=utf-8
set laststatus=2

" Cursor changes shape on INSERT
" iTerm2 - OSX
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" iTerm 2 - OSX - Tmux
" Should wrap in conditional
" let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
" let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"

set number
set backspace=indent,eol,start
set history=1000
set showcmd
set showmode
set gcr=a:blinkon0
set visualbell
set autoread
set mouse=a
set hidden

syntax on

" let mapleader=","

if filereadable(expand("~/.vim/vundles.vim"))
  source ~/.vim/vundles.vim
endif

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

