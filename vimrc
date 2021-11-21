" =============================================================================
" .vimrc
" Junhyeok Ahn ( junhyeokahn91@gmail.com )
" =============================================================================

" =============================================================================
" Plugin Setting
" =============================================================================
set enc=utf-8
set fenc=utf-8
set termencoding=utf-8
set nocompatible
syntax on
set ruler
set bs=indent,eol,start
set autoindent
set smartindent
set pastetoggle=<F8>
set nowrap
set textwidth=0
"set cursorline
"set lazyredraw
set colorcolumn=80
set tabstop=4
set shiftwidth=4
set softtabstop=4
set showtabline=1
set scrolloff=3
set ignorecase
set smartcase
set incsearch
set hlsearch
set expandtab
set wildmenu
set wildmode=list:longest,full
set wildignore=*.swp,*.swo,*.class
set mouse=a
set ttymouse=xterm2
set noswapfile
set nobackup
set list
set listchars=tab:»\ ,trail:·,extends:>,precedes:<
set clipboard=unnamed

let mapleader=','
let maplocalleader=','
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/
nnoremap <Leader>e :e %:h
nnoremap <silent> <F5> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

" =============================================================================
" Plugins
" =============================================================================
call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/seoul256.vim'
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/vim-slash'
Plug 'vim-scripts/a.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'SirVer/ultisnips'
Plug 'Townk/vim-autoclose'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'qpkorr/vim-bufkill'
Plug 'yegappan/grep'
Plug 'terryma/vim-multiple-cursors'
Plug 'rhysd/clever-f.vim'
Plug 'hdima/python-syntax'
Plug 'lervag/vimtex'
Plug 'junegunn/vim-journal'
Plug 'dhruvasagar/vim-table-mode'
Plug 'tpope/vim-surround'
Plug 'ludovicchabant/vim-gutentags'
Plug 'junhyeokahn/vim-xmark', { 'do': 'make' }
Plug 'tpope/vim-eunuch'
Plug 'machakann/vim-highlightedyank'
Plug 'rhysd/vim-clang-format'
Plug 'psliwka/vim-smoothie'
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
call plug#end()


" =============================================================================
" Plugin Setting
" =============================================================================
" 0. General
let g:gutentags_ctags_executable='/opt/homebrew/bin/ctags'
let Grep_Default_Options='-rn'
nnoremap <silent> <F3> :Rgrep<CR>
nnoremap <silent> <c-p> :FZF<CR>

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
let g:easy_align_delimiters = {}
let g:easy_align_delimiters['d'] = {
\ 'pattern': ' \ze\S\+\s*[;=]',
\ 'left_margin': 0, 'right_margin': 0
\ }

let g:table_mode_header_fillchar='='

let g:UltiSnipsUsePythonVersion=3
let g:UltiSnipsExpandTrigger="<Tab>"
let g:UltiSnipsJumpForwardTrigger="<c-n>"
let g:UltiSnipsJumpBackwardTrigger="<c-p>"

" 1. Coloer Scheme
let g:seoul256_background=237
colo seoul256
let g:airline_theme='zenburn'

set laststatus=2
highlight CursorLine cterm=none

" 2. C,C++
let g:cpp_class_scope_highlight=1
let g:cpp_member_variable_highlight=1
let g:cpp_experimental_template_highlight=1
let g:cpp_concepts_highlight=1
map <A-]> :vsp <CR> <C-w>l:exec("tag ".expand("<cword>"))<CR>

" 3. Python

" 4. Latex
let g:vimtex_compiler_latexmk={'callback':0, 'continuous':0}
let g:vimtex_quickfix_open_on_warning=0
let g:vimtex_view_method='skim'
let g:vimtex_fold_manual=1
let g:vimtex_matchparen_enabled=1
let g:vimtex_indent_enabled = 0

" 5. Filetype
au BufNewFile,BufRead *.txt set filetype=journal
au BufNewFile,BufRead CMakeLists.txt set filetype=cmake
au BufNewFile,BufRead *.urdf set filetype=xml
hi link markdownItalic Normal

" 7. Clang Format
augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto,javascript,arduino AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer yapf
  " Alternative: autocmd FileType python AutoFormatBuffer autopep8
  autocmd FileType rust AutoFormatBuffer rustfmt
  autocmd FileType vue AutoFormatBuffer prettier
augroup END
