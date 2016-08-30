" Create ~/.vim/autoload directory
if empty(glob("~/.config/nvim/autoload"))
  silent !mkdir ~/.config/nvim/autoload > /dev/null 2>&1
endif

" Create ~/.vim/colors directory
if empty(glob("~/.config/nvim/colors"))
  silent !mkdir ~/.config/nvim/colors > /dev/null 2>&1
endif

" Load plug
if empty(glob("~/.config/nvim/autoload/plug.vim"))
  execute '!curl -fLo ~/.config/nvim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

" Auto download colorscheme
if empty(glob("~/.config/nvim/colors/molokai.vim"))
  execute '!curl -fLo ~/.config/nvim/colors/molokai.vim https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim'
endif

call plug#begin('~/.config/nvim/plugged')

" Syntax Plugins
" Plug 'pangloss/vim-javascript'
Plug 'flowtype/vim-flow', {'for': ['javascript', 'javascript.jsx']}
Plug 'mxw/vim-jsx', {'for': 'javascript.jsx'}
Plug 'airblade/vim-gitgutter'
Plug 'derekwyatt/vim-scala', {'for': 'scala'}
Plug 'vim-ruby/vim-ruby', {'for': 'ruby'}
Plug 'cakebaker/scss-syntax.vim', {'for': 'scss'}
Plug 'fatih/vim-go', {'for': 'go'}
Plug 'gorodinskiy/vim-coloresque', {'for': ['css', 'scss', 'html']}
Plug 'rizzatti/dash.vim'
let g:dash_map = {
  \ 'php' : ['drupal', 'php', 'foundation'],
  \ 'yaml' : 'ansible'
  \ }

" Tagbar
Plug 'majutsushi/tagbar'
nmap tt :TagbarToggle<cr>

" Other Bundles
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
nmap <c-p> :FZF<cr>

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
Plug 'itchyny/lightline.vim'
Plug 'scrooloose/syntastic'
let g:syntastic_php_phpcs_args="--standard=Drupal"

Plug 'marcweber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'rking/ag.vim'

" Plug 'honza/vim-snippets'
Plug 'sirver/ultisnips'
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
" let g:UltiSnipsEditSplit = "vertical"

Plug 'sjl/gundo.vim'

Plug 'Raimondi/delimitMate'
let delimitMate_matchpairs = "(:),[:],{:}"

" Plug 'ervandew/supertab'
Plug 'mattn/emmet-vim'

Plug 'moll/vim-node'

Plug 'gcmt/taboo.vim'
let g:taboo_tab_format = '[%N| %f%m]'
let g:taboo_renamed_tab_format = '[%N| %l]'
nmap <leader>r :TabooRename

Plug 'duff/vim-scratch'
nmap <leader>s :Scratch<cr>

call plug#end()

" Syntax Mapping
" Drupal
au BufNewFile,BufRead *.module set filetype=php
au BufNewFile,BufRead *.yml set filetype=yaml
au BufNewFile,BufRead *.inc set filetype=php
au BufNewFile,BufRead *.install set filetype=php
autocmd FileType php autocmd BufWritePre <buffer> :%s/\s\+$//e
autocmd FileType javascript setlocal ts=4 sts=4 sw=4

" Color Scheme
colorscheme molokai

" Column 80
if (exists('+colorcolumn'))
  set colorcolumn=80
  highlight ColorColumn ctermbg=9
endif

syntax enable
set nocompatible
set incsearch
set mouse=h

" Enabling Omnitype
filetype plugin on
set omnifunc=syntaxcomplete#Complete

" Search mappings: These will make it so that going to the next item in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

" Splitting settings
set splitright
set splitbelow


let mapleader = ","
nmap <leader>t :tabnew<cr>
nmap <leader>w :tabclose<cr>

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
" hi Visual ctermbg=LightGreen

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

" Backup Files
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

" Folds
set foldmethod=syntax
set foldnestmax=3
set nofoldenable
let php_fold=1

" Scroll
set scrolloff=5
set sidescrolloff=15
set sidescroll=1

noremap <c-j> <c-w>j
noremap <c-k> <c-w>k
noremap <c-l> <c-w>l
noremap <c-h> <c-w>h

tnoremap ,, <c-\><c-n>

" Local Vimrc
if filereadable(expand("~/.config/nvim/nvimrc.local"))
  source ~/.config/nvim/nvimrc.local
endif

function UpdatePlugScript()
  execute '!rm ~/.config/nvim/autoload/plug.vim'
  execute '!curl -fLo ~/.config/nvim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endfunction

:command UpdatePlug call UpdatePlugScript()

" If no command line arguments
autocmd VimEnter *
  \   if filewritable(expand('%')) == 0 && argc() == 0
  \ |   e ~/todo.txt
  \ |   FZF

inoremap <c-s> <c-o>:Update<CR><CR>

" let g:deoplete#enable_at_startup = 1
