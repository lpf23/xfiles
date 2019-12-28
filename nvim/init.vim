" ~/xfiles/nvim/init.vim

" ensure vim-plug is installed and then load it
if empty(glob('~/xfiles/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/xfiles/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source ${HOME}/xfiles/nvim/init.vim
endif

""
"""
""""~~~~~~~~~~~~~~~~~~~~~~~
""       Plugins          |
""""~~~~~~~~~~~~~~~~~~~~~~~
"""
""

call plug#begin('~/xfiles/nvim/plugged')

" looks
Plug 'itchyny/lightline.vim'
Plug 'joshdick/onedark.vim'
Plug 'lilydjwg/colorizer', { 'on': 'ColorToggle' }

" general
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'ervandew/supertab'
Plug 'benekastah/neomake'
Plug 'tpope/vim-fugitive'   " :GStatus
Plug 'kien/ctrlp.vim'

" editing
Plug 'nathanaelkane/vim-indent-guides' " `,ig` to toggle
Plug 'junegunn/vim-easy-align'
Plug 'terryma/vim-multiple-cursors'
Plug 'sickill/vim-pasta'
Plug 'Raimondi/delimitMate'
Plug 'justinmk/vim-sneak'       " ,s{char}{char}
Plug 'mbbill/undotree'

Plug 'sheerun/vim-polyglot'     " https://github.com/sheerun/vim-polyglot
Plug 'pearofducks/ansible-vim'
Plug 'ekalinin/Dockerfile.vim'
Plug 'martinda/Jenkinsfile-vim-syntax'
Plug 'mtdl9/vim-log-highlighting'
Plug 'stephpy/vim-yaml'

" misc
Plug 'zyedidia/vim-snake', { 'on': 'Snake' }
Plug 'othree/html5.vim'
Plug 'kien/ctrlp.vim'
Plug 'sukima/xmledit'
Plug 'tomtom/tcomment_vim'

call plug#end()

""
"""
""""~~~~~~~~~~~~~~~~~~~~~~~
""       Settings         |
""""~~~~~~~~~~~~~~~~~~~~~~~
"""
""

set wildmode=longest,list   " get bash-like tab completions

set showmatch         " Show matching braces
set hlsearch          " switch on highlighting for the last used search pattern
set showcmd           " display incomplete commands
set mat=1             " Set the time to show matching braces to 1 second
set ignorecase        " Ignore case on searches
set smartcase         " Use case sensitive search if there is a capital letter in the search
set undolevels=1000   " Set the number of undos that are remembered
set number            " Show line numbers
set tabstop=2         " Use 2 space tabs
set softtabstop=2     " see multiple spaces as tabstops so <BS> does the right thing
set shiftwidth=2      " Use 2 space tabs
set expandtab         " Use spaces instead of tabs
set smarttab
set guifont=Monaco:h13 " Use Menlo size 13 font
set incsearch         " Incremental search: jump to the first occurrence of search while the user is still searching
set mouse=a           " Enable the mouse
set showcmd           " Show the current command in the bottom right
set autoindent        " Use autoindentation
set smartindent
set splitbelow        " Make horizontal splits below instead of above
set splitright        " Make vertical splits on the right
set scrolloff=3       " Start scrolling when the cursor is 3 lines away from the bottom of the window
set wrap              " Wrap long lines
set laststatus=2      " Always display the status line
set ruler             " Show the cursor position all the time
set cursorline        " Highlight the current line
set autoread          " Automatically reload the file when it is changed from an outside program
set nohlsearch        " Don't highlight search results
set omnifunc=syntaxcomplete#Complete " Enable omnicompletion

set backspace=indent,eol,start  " allow backspacing over everything in insert mode

set tags=tags;              " Look for tags files

set ffs=unix,dos,mac        " Unix as standard file type
set termencoding=utf-8      " Always utf8

set so=5                    " scroll lines above/below cursor
set sidescrolloff=5
set lazyredraw
set magic                   " for regular expressions

if has("vms")
  set nobackup      " do not keep a backup file, use versions instead
else
  set backup        " keep a backup file
endif

if has('mouse')
  set mouse=a
endif

" UNDO Directory
if !isdirectory($HOME . "/xfiles/nvim/undo")
    call mkdir($HOME . "/xfiles/nvim/undo", "p")
endif

set undodir=~/xfiles/nvim/undo " Set the undo directory
set undofile " Turn on persistent undo
set undolevels=100
set undoreload=1000

" BACKUP Directory
if !isdirectory($HOME . "/xfiles/nvim/backup")
    call mkdir($HOME . "/xfiles/nvim/backup", "p")
endif
set backupdir=~/xfiles/nvim/backup
set directory=~/xfiles/nvim/backup

""
"""
""""~~~~~~~~~~~~~~~~~~~~~~~
""       Mappings         |
""""~~~~~~~~~~~~~~~~~~~~~~~
"""
""

" map Leader
let mapleader = ","
" keep backward f search, remapping it to ,;
nnoremap <Leader>; ,

" in-line scrolling
nmap <Leader>j gj
nmap <Leader>k gk

" window keys
nnoremap <Leader>w< <C-w><
nnoremap <Leader>w> <C-w>>
nnoremap <Leader>w- <C-w>-
nnoremap <Leader>w+ <C-w>+
nnoremap <Leader>ws :split<CR>
nnoremap <Leader>wv :vsplit<CR>
nnoremap <Leader>wx :close<CR>

" CtrlP keys
nnoremap <Leader>pp :CtrlP<CR>
nnoremap <Leader>pf :CtrlP<CR>
nnoremap <Leader>pm :CtrlPMRUFiles<CR>
nnoremap <Leader>pr :CtrlPMRUFiles<CR>
nnoremap <Leader>pb :CtrlPBuffer<CR>

" Function keys
nnoremap <silent> <F2> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>
nnoremap <F3> :set hlsearch!<CR>
nnoremap <F5> :source $HOME/xfiles/nvim/init.vim<CR>
nnoremap <F6> :NERDTreeToggle<CR>
nnoremap <F7> :UndotreeToggle<CR>
nnoremap <F8> :ColorToggle<CR>
" indent whole file according to syntax rules
noremap <F9> gg=G

" override read-only permissions
cmap w!! %!sudo tee > /dev/null %

" allow ,, for vimsneak
nmap <Leader>, <Plug>SneakPrevious

" colorizer
nmap <Leader>tc :ColorToggle<CR>

" Make executing macros on selected lines easy by just pressing space
"vnoremap <Space> :call ExecMacro()<CR>

" Correctly indent the entire file
nnoremap <Leader>= :call IndentFile()<CR>

" Open nvimrc file
nnoremap <Leader>v :vsp ~/xfiles/nvim/init.vim<CR>

" Source nvimrc file
nnoremap <Leader>sv :source ~/xfiles/nvim/init.vim<CR>

" Run the current file
"nnoremap <Leader>r :Run<CR>
" Lint the current file (syntax check)
"nnoremap <Leader>s :SynCheck<CR>
" Fix any syntax highlighting glitches
"nnoremap <Leader>l :syntax sync fromstart<CR>
" Open the NERDTree with \n
"map <Leader>n :NERDTreeToggle<CR>

"let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1 " Use a bar in insert mode and a block in normal mode

""
"""
""""~~~~~~~~~~~~~~~~~~~~~~~
""      User Commands     |
""""~~~~~~~~~~~~~~~~~~~~~~~
"""
""

command! SynCheck :call SynCheck()  " Check for and report syntax errors
command! Vterm :vsp term://bash     " Open a terminal in a vertical split
command! Hterm :sp term://bash      " Open a terminal in a horizontal split

""
"""
""""~~~~~~~~~~~~~~~~~~~~~~~
""     Autocommands       |
""""~~~~~~~~~~~~~~~~~~~~~~~
"""
""

if has("autocmd")

  " detect .md as markdown instead of modula-2
  autocmd BufNewFile,BufReadPost *.md set filetype=markdown 

  " stop highlighting of underscores in markdown files
  autocmd BufNewFile,BufRead,BufEnter *.md,*.markdown :syntax match markdownIgnore "_" 
  
  " Highlight Lang as Java
  autocmd BufEnter,BufRead *.lang set syn=java 

  " Go into insert mode when the buffer switches to a terminal
  autocmd BufEnter,BufRead term://* call EnterTerminal() 

  " Check for syntax errors on file write
  autocmd! BufWritePost * SynCheck 

  augroup vimrcEx
    autocmd!

    " For all text files set 'textwidth' to 78 characters.
    autocmd FileType text setlocal textwidth=78

    " Trim whitespace onsave
    autocmd BufWritePre * %s/\s\+$//e

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") |
      \   execute "normal! g`\"" |
      \ endif

  augroup END

  augroup CursorLine 
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
  augroup END

endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis
                 \ | wincmd p | diffthis
endif

""
"""
""""~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
""     Plugin Customization       |
""""~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"""
""

"(see < https://github.com/joshdick/onedark.vim > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  if (has("termguicolors"))
    set termguicolors
  endif
endif

syntax on                   " Turn on syntax highlighting
syntax enable

filetype indent on              " Use filetype indentation
filetype plugin indent on       " Allow plugins to use filetype indentation

set background=dark             " Use a dark background
colorscheme onedark

let delimitMate_expand_cr = 1   " Expand 1 line down on enter pressed

let loaded_matchparen = 1       " Don't source the match paren plugin

" vim-sneak settings
hi SneakPluginTarget ctermfg=black ctermbg=181818

" disable colorizer at startup
let g:colorizer_startup = 0
let g:colorizer_nomap = 1

" Multiple cursors mappings to use Ctrl C instead of escape
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<C-c>'

let g:ctrlp_show_hidden = 1 " Show hidden files when searching with ctrlp

" Set some options for the lightline
let g:lightline = {
            \ 'colorscheme': 'onedark',
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ], 
            \             [ 'fugitive', 'relativepath', 'modified' ] 
            \           ],
            \  'right': [ [ 'lineinfo' ], 
            \             [ 'percent' ], 
            \             [ 'fileformat', 'fileencoding', 'filetype' ] ]
            \ },
            \ 'inactive': {
            \     'left': [ [ 'relativepath', 'modified' ] ],
            \    'right': [ [ 'lineinfo' ], [ 'percent' ] ]
            \ },
            \ 'component': {
            \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
            \ },
            \ 'component_visible_condition': {
            \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
            \ },
            \ 'component_function': {
            \   'fugitive': 'LightLineFugitive',
            \ },
            \ 'separator': { 'left': '', 'right': '' },
            \ 'subseparator': { 'left': '', 'right': '' }
            \ }

" Use >> for errors and warnings in Neomake (with slightly different fonts)
let g:neomake_error_sign = {
            \ 'text': '>>',
            \ 'texthl': 'ErrorMsg',
            \ }

let g:neomake_warning_sign = {
            \ 'text': '>>',
            \ 'texthl': 'WarningMsg',
            \ }

" Some additional options for tidy so it only shows errors
let g:neomake_html_tidy_maker = {
            \ 'args': ['-e', '-q', '--gnu-emacs', 'true', '--show-warnings', 'false'],
            \ 'errorformat': '%A%f:%l:%c: %trror: %m',
            \ }
let g:neomake_html_enabled_makers = ['tidy']

" Set the comment type for julia
" call tcomment#Define('julia', '# %s')
" Set the comment type for lua
" call tcomment#Define('lua', '-- %s')
" call tcomment#Define('d', '// %s')


"---------------------------------------
"|          Helper functions           |
"---------------------------------------

" Put the cursor in the correct position when insert mode is activated
function! IndentWithI()
    if len(Trim(getline('.'))) == 0
        " cc will correctly indent the cursor and switch to insert mode
        return "cc"
    else
        return "i"
    endif
endfunction

" Trim a string
function! Trim(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" Put the cursor in the right place when it enters a terminal buffer
function EnterTerminal()
    exec "norm! gg"
    exec "startinsert"
endfunction

" Autoindent the file without moving the cursor
function! IndentFile()
    execute "normal! mqHmwgg=G`wzt`q"
endfunction

" Open all the files in the current file's directory
function! OpenAll(ext)
    execute "lcd %:p:h"
    execute "args *." . a:ext
    execute "tab all"
endfunction

" Check the file for syntax errors
function! SynCheck()
    execute "w"
    execute "Neomake"
endfunction

" Execute the last recorded macro (useful for using visual mode to execute
" macros)
function! ExecMacro()
    execute "normal @q"
endfunction

" Open the current setup in MacVim
function! OpenInMacVim()
    execute "mksession! ~/.session.vim"
    execute "silent !mvim -S ~/.session.vim"
    execute "wqa"
endfunction

" Increment a selection of numbers
function! Incr()
    let a = line('.') - line("'<")
    let c = virtcol("'<")
    if a > 0
        execute 'normal! '.c.'|'.a."\<C-a>"
    endif
    normal `<
endfunction
vnoremap <C-a> :call Incr()<CR>

" Show the branch in lightline
function! LightLineFugitive()
    if exists("*fugitive#head")
        let _ = fugitive#head()
        return strlen(_) ? ' '._ : ''
    endif
    return ''
endfunction