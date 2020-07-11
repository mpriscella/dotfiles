" Create ~/.vim directory.
if empty(glob("~/.vim"))
  silent !mkdir ~/.vim > /dev/null 2>&1
endif

" Create ~/.vim/autoload directory.
if empty(glob("~/.vim/autoload"))
  silent !mkdir ~/.vim/autoload > /dev/null 2>&1
endif

" Load plug.
if empty(glob("~/.vim/autoload/plug.vim"))
  execute '!curl -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

if executable("git")
  call plug#begin('~/.vim/plugged')

  " Syntax Plugins.
  Plug 'pangloss/vim-javascript'
  Plug 'mxw/vim-jsx', {'for': ['javascript.jsx', 'javascript']}
  Plug 'airblade/vim-gitgutter'
  Plug 'derekwyatt/vim-scala', {'for': 'scala'}
  Plug 'vim-ruby/vim-ruby', {'for': 'ruby'}
  Plug 'cakebaker/scss-syntax.vim', {'for': 'scss'}
  Plug 'fatih/vim-go', {'for': 'go'}
  Plug 'gorodinskiy/vim-coloresque', {'for': ['css', 'scss', 'html']}
  Plug 'rizzatti/dash.vim'
  Plug 'fgsch/vim-varnish'
  let g:dash_map = {
    \ 'php' : ['drupal', 'php', 'foundation'],
    \ 'yaml' : 'ansible'
    \ }
  Plug 'evidens/vim-twig'

  " Tagbar.
  Plug 'majutsushi/tagbar'
  nmap tt :TagbarToggle<cr>

  " Other Bundles.
  Plug 'junegunn/rainbow_parentheses.vim'
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  nmap <c-p> :Files<cr>
  nmap <c-j> :Tags<cr>

  Plug 'dhruvasagar/vim-table-mode'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
  Plug 'scrooloose/syntastic'
  let g:syntastic_php_phpcs_args="--standard=Drupal"

  Plug 'marcweber/vim-addon-mw-utils'
  Plug 'tomtom/tlib_vim'
  Plug 'rking/ag.vim'

  Plug 'sjl/gundo.vim'

  Plug 'Raimondi/delimitMate'
  let delimitMate_matchpairs = "(:),[:],{:}"

  Plug 'mattn/emmet-vim'

  Plug 'moll/vim-node'

  Plug 'gcmt/taboo.vim'
  let g:taboo_tab_format = '[%N| %f%m]'
  let g:taboo_renamed_tab_format = '[%N| %l]'

  Plug 'duff/vim-scratch'

  call plug#end()
else
  echo "Warning:"
  echo " - git must be installed to install plugins."
endif

" Clipboard.
set clipboard+=unnamedplus

scriptencoding utf-8
set encoding=utf-8

" Syntax Mapping.
" Drupal.
au BufNewFile,BufRead *.module set filetype=php
au BufNewFile,BufRead *.theme set filetype=php
au BufNewFile,BufRead *.yml set filetype=yaml
au BufNewFile,BufRead *.inc set filetype=php
au BufNewFile,BufRead *.install set filetype=php
au BufNewFile,BufRead *.Jenkinsfile set filetype=groovy
autocmd FileType php autocmd BufWritePre <buffer> :%s/\s\+$//e

au BufNewFile,BufRead *.js set filetype=javascript.jsx
autocmd FileType javascript setlocal ts=4 sts=4 sw=4
autocmd FileType javascript.jsx setlocal ts=4 sts=4 sw=4

" Column 80.
if (exists('+colorcolumn'))
  set colorcolumn=80
  highlight ColorColumn ctermbg=59
endif

syntax enable
set nocompatible
set incsearch
set mouse=h

" Enabling Omnitype.
filetype plugin on
set omnifunc=syntaxcomplete#Complete

" Search mappings: These will make it so that going to the next item in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

" Splitting settings.
set splitright
set splitbelow

let mapleader = ","
nmap <leader>t :tabnew<cr>
nmap <leader>w :tabclose<cr>

" Tabs.
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

hi Visual guifg=#99ff33

nmap <leader>r :TabooRename
nmap <leader>s :Scratch<cr>

try
  set relativenumber
endtry
set number
set backspace=2
set history=1000
set showcmd
set showmode
set gcr=a:blinkon0
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
set foldmethod=syntax
set foldnestmax=3
set nofoldenable
let php_fold=1

" Scroll.
set scrolloff=5
set sidescrolloff=15
set sidescroll=1

noremap <c-j> <c-w>j
noremap <c-k> <c-w>k
noremap <c-l> <c-w>l
noremap <c-h> <c-w>h

tnoremap ,, <c-\><c-n>

" Local Vimrc.
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

:imap <c-u> <esc>gUiwi

inoremap <c-s> <c-o>:Update<CR><CR>
