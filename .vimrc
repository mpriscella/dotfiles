" ~/.vimrc

" Section: Bootstrap

let g:config_dir = expand('~/.vim')
if has('nvim')
  let g:config_dir = expand('~/.config/nvim')
endif

" Create config directory if it doesn't exist.
if !isdirectory(g:config_dir)
  call mkdir(g:config_dir)
endif

" Create autoload directory if it doesn't exist.
if !isdirectory(g:config_dir . "/autoload")
  call mkdir(g:config_dir . "/autoload")
endif

" Load vim-plug (https://github.com/junegunn/vim-plug).
if !filereadable(g:config_dir . '/autoload/plug.vim')
  let $PLUG_FILE = g:config_dir . '/autoload/plug.vim'
  silent execute '!curl -fLo $PLUG_FILE https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

" Section: Load Plugins

if executable('git')
  call plug#begin(g:config_dir . '/plugged')

  Plug 'tpope/vim-sensible'

  " Syntax plugins.
  Plug 'pangloss/vim-javascript', {'for': 'javascript'}
  Plug 'fatih/vim-go', {'for': 'go'}
  Plug 'fgsch/vim-varnish'

  " Git plugins.
  Plug 'tpope/vim-fugitive'
  Plug 'airblade/vim-gitgutter'

  Plug 'tpope/vim-commentary'
  Plug 'junegunn/rainbow_parentheses.vim' " Is this still active?
  Plug 'tpope/vim-surround'
  Plug 'Raimondi/delimitMate'
  let delimitMate_matchpairs = "(:),[:],{:}"

  Plug 'gcmt/taboo.vim'
  let g:taboo_tab_format = '[%N| %f%m]'
  let g:taboo_renamed_tab_format = '[%N| %l]'

  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  nmap <c-p> :Files<cr>

  call plug#end()
else
  echo "Warning:"
  echo " - git must be installed to install plugins."
endif

set relativenumber
set number
set showcmd
set hidden
set modelines=5
set autoindent
set smartindent
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set ignorecase
set nowrap
set linebreak
set clipboard^=unnamed,unnamedplus
set omnifunc=syntaxcomplete#Complete
set splitright
set splitbelow
if (exists('+colorcolumn'))
  set colorcolumn=80
  highlight ColorColumn ctermbg=59
endif

" Search mappings: These will make it so that going to the next item in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

" Remove trailing whitespace on save.
autocmd BufWritePre * :%s/\s\+$//e

" Section: Tabs

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

nmap <leader>r :TabooRename

" Navigate split windows.
noremap <c-j> <c-w>j
noremap <c-k> <c-w>k
noremap <c-l> <c-w>l
noremap <c-h> <c-w>h

tnoremap ,, <c-\><c-n>

" Cursor modes.
let &t_SI.="\e[5 q" " Set INSERT mode cursor to 'blinking vertical bar'.
let &t_EI.="\e[1 q" " Set NORMAL mode cursor to 'blinking block'.
let &t_ti.="\e[1 q"
let &t_te.="\e[0 q"

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
