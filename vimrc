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
Plug 'junhyeokahn/seoul256.vim'
Plug 'junegunn/vim-slash'
Plug 'vim-scripts/a.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'thomasfaingnaert/vim-lsp-snippets'
Plug 'thomasfaingnaert/vim-lsp-ultisnips'
Plug 'Townk/vim-autoclose'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'qpkorr/vim-bufkill'
Plug 'yegappan/grep'
Plug 'terryma/vim-multiple-cursors'
Plug 'rhysd/clever-f.vim'
Plug 'vim-python/python-syntax'
Plug 'lervag/vimtex'
Plug 'junegunn/vim-journal'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-eunuch'
Plug 'machakann/vim-highlightedyank'
Plug 'psliwka/vim-smoothie'
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'ekalinin/Dockerfile.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

call plug#end()

" =============================================================================
" Plugin Setting
" =============================================================================
"let g:gutentags_ctags_executable='/opt/homebrew/bin/ctags'
let Grep_Default_Options='-rn'

let g:UltiSnipsUsePythonVersion=3
let g:UltiSnipsExpandTrigger="<Tab>"
"let g:UltiSnipsJumpForwardTrigger="<c-n>"
"let g:UltiSnipsJumpBackwardTrigger="<c-p>"

let g:seoul256_background=237
colo seoul256
let g:airline_theme='zenburn'

set laststatus=2
highlight CursorLine cterm=none

let g:cpp_class_scope_highlight=1
let g:cpp_member_variable_highlight=1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_experimental_template_highlight=1
let g:cpp_concepts_highlight=1

let g:python_highlight_all = 1

au BufNewFile,BufRead *.txt set filetype=journal
au BufNewFile,BufRead CMakeLists.txt set filetype=cmake
au BufNewFile,BufRead *.urdf set filetype=xml
hi link markdownItalic Normal

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

nnoremap <silent> <c-p> :FZF<CR>
nnoremap <silent> <F3> :Rgrep<CR>

nnoremap <leader>f :LspReferences<CR>
nnoremap <leader>r :LspRename<CR>
nnoremap <leader>d :LspDocumentDiagnostics<CR>
nnoremap <silent> <c-]> :LspDefinition<CR>

"let g:lsp_diagnostics_enabled = 0

"cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 ..
if has("unix")
    let s:uname = system("uname")
    if s:uname == "Darwin\n"
        " macosx for clangd (6.0)
        if executable('clangd')
            augroup lsp_clangd
                autocmd!
                autocmd User lsp_setup call lsp#register_server({
                            \ 'name': 'clangd',
                            \ 'cmd': {server_info->['clangd']},
                            \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
                            \ })
            augroup end
        endif
    else
        " linux for clangd-9
        if executable('clangd-9')
            augroup lsp_clangd
                autocmd!
                autocmd User lsp_setup call lsp#register_server({
                            \ 'name': 'clangd',
                            \ 'cmd': {server_info->['clangd-9']},
                            \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
                            \ })
            augroup end
        endif
    endif
endif

" python ($ pip install python-language-server)
if executable('pyls')
    augroup lsp_clangd
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'pyls',
                    \ 'cmd': {server_info->['pyls']},
                    \ 'whitelist': ['python'],
                    \ })
    augroup end
endif

let g:lsp_highlights_enabled = 1
let g:lsp_textprop_enabled = 1
