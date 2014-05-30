execute pathogen#infect()

set nocompatible

set number
set backspace=indent,eol,start
set history=1000
set showcmd
set showmode
set gcr=a:blinkon0
set visualbell
set autoread

set hidden

syntax on

let mapleader=","

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
