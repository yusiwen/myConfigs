" Neo/vim Settings
" ===

" General {{{
set mouse=nv                 " Disable mouse in command-line mode
set modeline                 " automatically setting options from modelines
set report=0                 " Don't report on line changes
set errorbells               " Trigger bell on error
set visualbell               " Use visual bell instead of beeping
set signcolumn=yes           " Always show signs column
set hidden                   " hide buffers when abandoned instead of unload
set fileformats=unix,dos,mac " Use Unix as the standard file type
set magic                    " For regular expressions turn magic on
set path+=**                 " Directories to search when using gf and friends
set isfname-==               " Remove =, detects filename in var=/foo/bar
set virtualedit=block        " Position cursor anywhere in visual block
set synmaxcol=1000           " Don't syntax highlight long lines
set formatoptions+=1         " Don't break lines after a one-letter word
set formatoptions-=t         " Don't auto-wrap text
if has('patch-7.3.541')
  set formatoptions+=j       " Remove comment leader when joining lines
endif

if has('vim_starting')
  set encoding=utf-8
  scriptencoding utf-8
endif

" What to save for views and sessions:
set viewoptions=folds,cursor,curdir,slash,unix
set sessionoptions=curdir,help,tabpages,winsize

if has('mac') && has('vim_starting')
  let g:clipboard = {
    \   'name': 'macOS-clipboard',
    \   'copy': {
    \      '+': 'pbcopy',
    \      '*': 'pbcopy',
    \    },
    \   'paste': {
    \      '+': 'pbpaste',
    \      '*': 'pbpaste',
    \   },
    \   'cache_enabled': 0,
    \ }
endif

if has('clipboard')
  set clipboard& clipboard+=unnamedplus
endif

" }}}
" Wildmenu {{{
" --------
if has('wildmenu')
  if ! has('nvim')
    set wildmode=list:longest
  endif

  " if has('nvim')
  " 	set wildoptions=pum
  " else
  " 	set nowildmenu
  " 	set wildmode=list:longest,full
  " 	set wildoptions=tagfile
  " endif
  set wildignorecase
  set wildignore+=.git,.hg,.svn,.stversions,*.pyc,*.spl,*.o,*.out,*~,%*
  set wildignore+=*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store
  set wildignore+=**/node_modules/**,**/bower_modules/**,*/.sass-cache/*
  set wildignore+=application/vendor/**,**/vendor/ckeditor/**,media/vendor/**
  set wildignore+=__pycache__,*.egg-info,.pytest_cache,.mypy_cache/**
  set wildcharm=<C-z>  " substitue for 'wildchar' (<Tab>) in macros
endif

" }}}
" Vim Directories {{{
" ---------------
set undofile swapfile nobackup
set directory=$DATA_PATH/swap//,$DATA_PATH,~/tmp,/var/tmp,/tmp
set undodir=$DATA_PATH/undo//,$DATA_PATH,~/tmp,/var/tmp,/tmp
set backupdir=$DATA_PATH/backup/,$DATA_PATH,~/tmp,/var/tmp,/tmp
set viewdir=$DATA_PATH/view/
set spellfile=$VIM_PATH/spell/en.utf-8.add

" History saving
set history=2000

if has('nvim') && ! has('win32') && ! has('win64')
  set shada=!,'300,<50,@100,s10,h
else
  set viminfo='300,<10,@50,h,n$DATA_PATH/viminfo
endif

augroup user_persistent_undo
  autocmd!
  au BufWritePre /tmp/*          setlocal noundofile
  au BufWritePre COMMIT_EDITMSG  setlocal noundofile
  au BufWritePre MERGE_MSG       setlocal noundofile
  au BufWritePre *.tmp           setlocal noundofile
  au BufWritePre *.bak           setlocal noundofile
augroup END

" If sudo, disable vim swap/backup/undo/shada/viminfo writing
if $SUDO_USER !=# '' && $USER !=# $SUDO_USER
    \ && $HOME !=# expand('~'.$USER)
    \ && $HOME ==# expand('~'.$SUDO_USER)

  set noswapfile
  set nobackup
  set nowritebackup
  set noundofile
  if has('nvim')
    set shada="NONE"
  else
    set viminfo="NONE"
  endif
endif

" Secure sensitive information, disable backup files in temp directories
if exists('&backupskip')
  set backupskip+=/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*
  set backupskip+=.vault.vim
endif

" Disable swap/undo/viminfo/shada files in temp directories or shm
augroup user_secure
  autocmd!
  silent! autocmd BufNewFile,BufReadPre
    \ /tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim
    \ setlocal noswapfile noundofile nobackup nowritebackup viminfo= shada=
augroup END

" }}}
" Tabs and Indents {{{
" ----------------
set textwidth=80    " Text width maximum chars before wrapping
set expandtab       " Expand tabs to spaces.
set tabstop=2       " The number of spaces a tab is
set softtabstop=2   " While performing editing operations
set shiftwidth=2    " Number of spaces to use in auto(indent)
set smarttab        " Tab insert blanks according to 'shiftwidth'
set autoindent      " Use same indenting on new lines
set smartindent     " Smart autoindenting on new lines
set shiftround      " Round indent to multiple of 'shiftwidth'

" }}}
" Timing {{{
" ------
set timeout ttimeout
set timeoutlen=750  " Time out on mappings
set updatetime=400  " Idle time to write swap and trigger CursorHold
set ttimeoutlen=10  " Time out on key codes

" }}}
" Searching {{{
" ---------
set ignorecase      " Search ignoring case
set smartcase       " Keep case when searching with *
set infercase       " Adjust case in insert completion mode
set incsearch       " Incremental search
set wrapscan        " Searches wrap around the end of the file
set showmatch       " Jump to matching bracket
set matchpairs+=<:> " Add HTML brackets to pair matching
set matchtime=1     " Tenths of a second to show the matching paren
set cpoptions-=m    " showmatch will wait 0.5s or until a char is typed
set showfulltag     " Show tag and tidy search in completion
"set complete=.      " No wins, buffs, tags, include scanning

if exists('+inccommand')
  set inccommand=nosplit
endif

if executable('rg')
  set grepformat=%f:%l:%m
  let &grepprg = 'rg --vimgrep' . (&smartcase ? ' --smart-case' : '')
elseif executable('ag')
  set grepformat=%f:%l:%m
  let &grepprg = 'ag --vimgrep' . (&smartcase ? ' --smart-case' : '')
endif

" }}}
" Behavior {{{
" --------
set wrap                        " Wrap by default
set linebreak                   " Break long lines at 'breakat'
set breakat=\ \	;:,!?           " Long lines break chars
set nostartofline               " Cursor in same column for few commands
set whichwrap+=h,l,<,>,[,],~    " Move to following line on certain keys
set splitbelow splitright       " Splits open bottom right
set switchbuf=useopen,usetab    " Jump to the first open window in any tab
set switchbuf+=vsplit           " Switch buffer behavior to vsplit
set backspace=indent,eol,start  " Intuitive backspacing in insert mode
set diffopt=filler,iwhite       " Diff mode: show fillers, ignore whitespace
set completeopt=menuone         " Always show menu, even for one item
set completeopt+=noselect       " Do not select a match in the menu

if has('patch-7.4.775')
  " Do not insert any text for a match until the user selects from menu
  set completeopt+=noinsert
endif

if has('patch-8.1.0360')
  set diffopt+=internal,algorithm:patience
  " set diffopt=indent-heuristic,algorithm:patience
endif

" }}}
" Editor UI {{{
" --------------------
set noshowmode          " Don't show mode in cmd window
set shortmess=aoOTI     " Shorten messages and don't show intro
set scrolloff=2         " Keep at least 2 lines above/below
set sidescrolloff=5     " Keep at least 5 lines left/right
set number              " Show line numbers
set ruler               " Enable default status ruler
set list                " Show hidden characters
set cursorline          " Enable cursorline

set showtabline=2       " Always show the tabs line
set winwidth=30         " Minimum width for active window
set winminwidth=10      " Minimum width for inactive windows
set winheight=4         " Minimum height for active window
set winminheight=1      " Minimum height for inactive window
set pumheight=15        " Pop-up menu's line height
set helpheight=12       " Minimum help window height
set previewheight=12    " Completion preview height

set showcmd             " Show command in status line
set cmdheight=2         " Height of the command line
set cmdwinheight=5      " Command-line lines
set equalalways         " Resize windows on split or close
set laststatus=2        " Always show a status line
"set colorcolumn=80      " Highlight the 80th character limit
set display+=lastline

if has('folding')
  set foldenable
  set foldmethod=syntax
  set foldlevelstart=99
endif

" UI Symbols
set showbreak=↪
" set listchars=tab:\▏\ ,extends:⟫,precedes:⟪,nbsp:␣,trail:·
" tab: U+25BA, extends: U+00BB, precedes:U+00AB, trail:U+2017, eol:U+00AC
set listchars=tab:►\ ,extends:»,precedes:«,trail:␣,eol:¬
set fillchars=vert:│,fold:─

if has('patch-7.4.314')
  " Do not display completion messages
  set shortmess+=c
endif

if has('patch-7.4.1570')
  " Do not display message when editing files
  set shortmess+=F
endif

if has('conceal') && v:version >= 703
  " For snippet_complete marker
  set conceallevel=2 concealcursor=niv
endif

if exists('+previewpopup')
  set previewpopup=height:10,width:60
endif

" Pseudo-transparency for completion menu and floating windows
if &termguicolors
  if exists('&pumblend')
    set pumblend=10
  endif
  if exists('&winblend')
    set winblend=10
  endif
endif

" }}}

" vim: set foldmethod=marker ts=2 sw=2 tw=80 noet :
