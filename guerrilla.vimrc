set encoding=utf-8

syntax enable

filetype plugin on
set omnifunc=syntaxcomplete#Complete

set splitright
set splitbelow
set nocompatible
set incsearch

set laststatus=2
set statusline=

if executable('git')
  function! GitBranch()
    return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
  endfunction

  function! StatuslineGit()
    let l:branchname = GitBranch()
    return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
  endfunction

  set statusline+=%#PmenuSel#
  set statusline+=%{StatuslineGit()}
  set statusline+=%#LineNr#
endif

set statusline+=\ %t
set statusline+=\ %h
set statusline+=%m
set statusline+=%r
set statusline+=%=
set statusline+=%y
set statusline+=‹‹%l:%c››

if has('mouse')
  set mouse=h
endif

try
  set relativenumber
endtry
set number
set backspace=2
set history=1000
set showcmd
set showmode
set gcr=a:blinkon0
set visualbell
set autoread
set hidden

" Backup Files.
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

" Folds.
if has('foldmethod')
  set foldmethod=indent
  set foldnestmax=3
  set nofoldenable
endif

" Scroll.
set scrolloff=5
set sidescrolloff=15
set sidescroll=1

" Shortcuts for moving around splits.
noremap <c-j> <c-w>j
noremap <c-k> <c-w>k
noremap <c-l> <c-w>l
noremap <c-h> <c-w>h

nmap <c-p> :e.<cr>

let mapleader = ","

" Tabs.
nmap <leader>t :tabnew<cr>
nmap <leader>w :tabclose<cr>
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

nmap <leader>m1 :tabm 0<cr>
nmap <leader>m2 :tabm 1<cr>
nmap <leader>m3 :tabm 2<cr>
nmap <leader>m4 :tabm 3<cr>
nmap <leader>m5 :tabm 4<cr>
nmap <leader>m6 :tabm 5<cr>
nmap <leader>m7 :tabm 6<cr>
nmap <leader>m8 :tabm 7<cr>
nmap <leader>m9 :tabm 8<cr>

autocmd BufWritePost *vimrc :source ~/.vimrc

" Automatically remove trailing whitespace from files.
autocmd BufWritePre * :%s/\s\+$//e

" Drupal.
au BufNewFile,BufRead *.module set filetype=php
au BufNewFile,BufRead *.yml set filetype=yaml
au BufNewFile,BufRead *.inc set filetype=php
au BufNewFile,BufRead *.install set filetype=php

" Javascript.
" autocmd FileType javascript setlocal ts=2 sts=2 sw=2
