" vim-plug configuration
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'airblade/vim-gitgutter'
Plug 'bfrg/vim-jq'
Plug 'Yggdroot/indentLine'
Plug 'neoclide/jsonc.vim'
Plug 'bfrg/vim-jqplay'

" Add plugins to &runtimepath
call plug#end()

set nocompatible
syntax on
filetype plugin indent on

set background=dark
set encoding=utf-8
set ts=2
set expandtab
set shiftwidth=2
set number relativenumber
set splitbelow splitright
set linebreak

let mapleader = ","

" Prevent any use of the cursor keys by mapping them to 'no operation'
noremap <Up>    <nop>
noremap <Down>  <nop>
noremap <Left>  <nop>
noremap <Right> <nop>

" Disables automatic commenting on newline
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

nnoremap <leader>w :w<cr>
nnoremap <leader>q :q<cr>

" Integrate Limelight with Goyo
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" Shortcutting split navigation, saves a keypress
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Edit and source .vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :so $MYVIMRC<cr>

" Remove all trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Check leading whitespace
set listchars=tab:▸·,eol:¬
nnoremap <silent> <leader>l :set list!<cr>

"devcontainer.json files contain comments, gah!
autocmd BufNewFile,BufRead devcontainer.json set ft=jsonc

" Quick insertions of various patterns when writing markdown
autocmd FileType markdown inoremap ii -<space>[<space>]<space>
autocmd FileType markdown inoremap ppp :point_right:<space>

" -------------------------------------------------------------------
" Linting and formatting with ALE
" -------------------------------------------------------------------
let g:ale_completion_enabled = 1
let g:ale_sign_column_always = 1
let g:ale_linters_explicit = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 1
let g:ale_linters = {
      \ 'sh':       ['shellcheck', 'language_server'],
      \ 'yaml':     ['yamllint'],
      \ 'markdown': ['markdownlint'],
      \ }
let g:ale_fixers = {
      \ 'sh':       ['shfmt'],
      \ '*':        ['remove_trailing_lines', 'trim_whitespace'],
      \}

" shfmt options:
" -i 2 : indent with 2 spaces
" -bn  : binary ops (&&, |) may start a line
" -ci  : switch cases will be indented
" -sr  : redirect ops will be followed by a space
let g:ale_sh_shfmt_options='-i 2 -bn -ci -sr'
let g:ale_markdown_markdownlint_options = '--config ~/.markdownlintrc'

nmap <silent> <F8> :ALENextWrap<cr>
nmap <silent> <S-F8> :ALEPreviousWrap<cr>
nmap <silent> <leader>ad :ALEGoToDefinition<cr>
nmap <silent> <leader>ar :ALEFindReferences<cr>
" -------------------------------------------------------------------

" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

" Bind Ctrl-P to use fzf 'Files' command now
nnoremap <c-p> :Files<cr>

" Improve search UI
set hlsearch incsearch
nnoremap <leader>h :set hls!<cr>

" See https://github.com/neovim/neovim/issues/5559#issuecomment-258143499
let g:is_bash = 1

nnoremap [[ :bprev<cr>
nnoremap ]] :bnext<cr>

" Ignore markdown complaints about underscores
" (see https://github.com/tpope/vim-markdown/issues/21)
autocmd FileType markdown syn match markdownError "\w\@<=\w\@="

highlight clear SignColumn
set cursorline
hi CursorLine term=none cterm=bold ctermbg=darkgrey
hi CursorLineNr cterm=none

" Make comments italic
" See https://stackoverflow.com/questions/3494435/vimrc-make-comments-italic
hi Comment cterm=italic gui=italic
set t_ZH=[3m
set t_ZR=[23m

hi MatchParen cterm=none ctermbg=green ctermfg=white

set nobackup
set nowritebackup
set laststatus=2

function! s:goyo_enter()
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
endfunction

function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()

let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name'
      \ },
      \ }

" YAML help - will use installed `yamllint` via ALE, and
" sets tab options appropriately, and also configures the
" indentLine plugin - to start disabled, toggleable with <leader>i
" and the concealcursor value is to address an issue with background
" colours with cursorline.
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
nnoremap <leader>i :IndentLinesToggle<CR>
let g:indentLine_char = '┊'
let g:indentLine_enabled = 0
let g:indentLine_concealcursor = 0

set noswapfile nobackup

autocmd BufNewFile,BufRead /tmp/journal.* :autocmd TextChanged,TextChangedI <buffer> silent write
