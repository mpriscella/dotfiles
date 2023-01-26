" Create ~/.vim directory.
if empty(glob("~/.vim"))
  silent !mkdir ~/.vim > /dev/null 2>&1
endif

" Create ~/.vim/autoload directory.
if empty(glob("~/.vim/autoload"))
  silent !mkdir ~/.vim/autoload > /dev/null 2>&1
endif

" Load vim-plug (https://github.com/junegunn/vim-plug).
if empty(glob("~/.vim/autoload/plug.vim"))
  silent execute '!curl -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

if executable("git")
  call plug#begin('~/.vim/plugged')

  Plug 'tpope/vim-sensible'

  " Syntax Plugins.
  Plug 'pangloss/vim-javascript'
  Plug 'mxw/vim-jsx', {'for': ['javascript.jsx', 'javascript']}
  Plug 'airblade/vim-gitgutter'
  Plug 'derekwyatt/vim-scala', {'for': 'scala'}
  Plug 'cakebaker/scss-syntax.vim', {'for': 'scss'}
  Plug 'fatih/vim-go', {'for': 'go'}
  Plug 'gorodinskiy/vim-coloresque', {'for': ['css', 'scss', 'html']}
  Plug 'fgsch/vim-varnish'
  Plug 'evidens/vim-twig'

  if executable("ctags-exuberant")
    Plug 'majutsushi/tagbar'
    nmap tt :TagbarToggle<cr>
  endif

  " Other Bundles.
  Plug 'junegunn/rainbow_parentheses.vim'
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  nmap <c-p> :Files<cr>

  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
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

  au BufNewFile,BufRead *.gitconfig set filetype=gitconfig

  call plug#end()
else
  echo "Warning:"
  echo " - git must be installed to install plugins."
endif

" Clipboard.
set clipboard=unnamed

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

" Column 80.
if (exists('+colorcolumn'))
  set colorcolumn=80
  highlight ColorColumn ctermbg=59
endif

syntax enable
set nocompatible
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
set showcmd
set showmode
set gcr=a:blinkon0
set hidden

" Backup Files.
set noswapfile
set nobackup
set nowb

set smartindent
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set ignorecase

set nowrap
set linebreak

" Folds.
set foldmethod=syntax
set foldnestmax=3
set nofoldenable
let php_fold=1

" Scroll.
set sidescroll=1

noremap <c-j> <c-w>j
noremap <c-k> <c-w>k
noremap <c-l> <c-w>l
noremap <c-h> <c-w>h

tnoremap ,, <c-\><c-n>

" Load local Vimrc if it exists.
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

:imap <c-u> <esc>gUiwi

" Cursor modes.
let &t_SI.="\e[5 q" " Set INSERT mode cursor to 'blinking vertical bar'.
let &t_EI.="\e[1 q" " Set NORMAL mode cursor to 'blinking block'.
let &t_ti.="\e[1 q"
let &t_te.="\e[0 q"

inoremap <c-s> <c-o>:Update<CR><CR>

