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
set number
set bs=indent,eol,start
set autoindent
set smartindent
set pastetoggle=<F8>
set nowrap
set textwidth=0
set colorcolumn=80
set cursorline
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
set laststatus=2
highlight CursorLine cterm=none
let mapleader=','
let maplocalleader=','
nnoremap <leader>s :%s/\<<C-r><C-w>\>/
nnoremap <leader>e :e %:h
nnoremap <silent> <F3> :Rgrep<CR>

" =============================================================================
" Plugins
" =============================================================================
call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-slash'
Plug 'vim-scripts/a.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'arcticicestudio/nord-vim'
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
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'segeljakt/vim-silicon'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'puremourning/vimspector'
call plug#end()

" =============================================================================
" Plugin Setting
" =============================================================================
let Grep_Default_Options='-rn'

let g:UltiSnipsUsePythonVersion=3
let g:UltiSnipsExpandTrigger="<Tab>"

colorscheme nord
let g:airline_theme='nord'

let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline#extensions#branch#enabled = 1
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''


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

" https://github.com/junegunn/fzf.vim/issues/47#issuecomment-646115681
fun! FzfOmniFiles()
  let git_status = system('git status')
  if v:shell_error != 0
    :Files
  else
    let git_files_cmd = ":GitFiles --exclude-standard --cached --others"
    call fzf#vim#gitfiles('--exclude-standard --cached --others', {'dir': getcwd()})
  endif
endfun
nnoremap <silent> <C-p> :call FzfOmniFiles()<CR>


nnoremap <leader>lf :LspReferences<CR>
nnoremap <leader>lr :LspRename<CR>
nnoremap <leader>ld :LspDocumentDiagnostics<CR>
nnoremap <leader>lq :LspCodeAction<CR>
nnoremap <leader>lh :LspHover<CR>
nnoremap <silent> <c-]> :LspDefinition<CR>

let g:lsp_document_code_action_signs_enabled = 0

if has("unix")
    let s:uname = system("uname")
    if s:uname == "Darwin\n"
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
let g:lsp_diagnostics_enabled = 1

let g:silicon = {
      \   'theme':              'Nord',
      \   'font':                  'Hack',
      \   'background':         '#AAAAFF',
      \   'shadow-color':       '#555555',
      \   'line-pad':                   2,
      \   'pad-horiz':                  0,
      \   'pad-vert':                   0,
      \   'shadow-blur-radius':         0,
      \   'shadow-offset-x':            0,
      \   'shadow-offset-y':            0,
      \   'line-number':           v:true,
      \   'round-corner':          v:false,
      \   'window-controls':       v:true,
      \ }
let g:silicon['output'] = '~/Pictures/silicon-{time:%Y-%m-%d-%H%M%S}.png'

nmap <leader>dc <Plug>VimspectorContinue
nmap <leader>ds <Plug>VimspectorStop
nmap <leader>db <Plug>VimspectorToggleBreakpoint
nmap <leader>dn <Plug>VimspectorStepOver
nmap <leader>di <Plug>VimspectorStepInto
nmap <leader>do <Plug>VimspectorStepOut
nnoremap <leader>dx :VimspectorReset
let g:vimspector_sign_priority = {
  \    'vimspectorBP':          999,
  \    'vimspectorBPCond':      999,
  \    'vimspectorBPLog':       3,
  \    'vimspectorBPDisabled':  3,
  \    'vimspectorNonActivePC': 3,
  \    'vimspectorPC':          999,
  \    'vimspectorPCBP':        999,
  \ }
