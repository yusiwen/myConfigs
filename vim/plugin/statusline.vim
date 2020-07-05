" My statusline
" ------------------------------------

" Statusline {{{
function! EditMode()
  redraw

  "n	Normal
  "no	Operator-pending
  "v	Visual by character
  "V	Visual by line
  "CTRL-V	Visual blockwise
  "s	Select by character
  "S	Select by line
  "CTRL-S	Select blockwise
  "i	Insert
  "R	Replace |R|
  "Rv	Virtual Replace |gR|
  "c	Command-line
  "cv	Vim Ex mode |gQ|
  "ce	Normal Ex mode |Q|
  "r	Hit-enter prompt
  "rm	The -- more -- prompt
  "r?	A |:confirm| query of some sort
  "!	Shell or external command is executing
  if (mode() =~# '\v(n|no)')
    execute 'hi User8 cterm=NONE ctermfg=248 ctermbg=235 guifg=#a8a8a8 guibg=#262626'
  elseif (mode() =~# '\v(v|V)')
    execute 'hi User8 cterm=NONE ctermfg=255 ctermbg=6 guifg=#eeeeee guibg=#528b8b'
  elseif (mode() ==# '')
    execute 'hi User8 cterm=NONE ctermfg=255 ctermbg=6 guifg=#eeeeee guibg=#528b8b'
    return 'X'
  elseif (mode() ==# 'R')
    execute 'hi User8 cterm=NONE ctermfg=255 ctermbg=3 guifg=#eeeeee guibg=#cc8800'
  elseif (mode() ==# 'i')
    execute 'hi User8 cterm=NONE ctermfg=255 ctermbg=2 guifg=#eeeeee guibg=#719611'
  else
    execute 'hi User8 cterm=NONE ctermfg=248 ctermbg=235 guifg=#a8a8a8 guibg=#262626'
  endif

  return mode()
endfunction

function! FileMode()
  redraw
  let s:modes = badge#mode('R', 'Z')
  if empty(s:modes)
    let s:modes = '#'
    execute 'hi User4 ctermfg=242 ctermbg=235 guifg=#6c6c6c guibg=#262626'
  elseif s:modes ==# 'R'
    execute 'hi User4 cterm=bold ctermfg=1 ctermbg=235 guifg=#aa4450 guibg=#262626 gui=bold'
  elseif s:modes ==# 'Z'
    execute 'hi User4 cterm=bold ctermfg=1 ctermbg=235 guifg=#aa4450 guibg=#262626 gui=bold'
  endif
  return s:modes
endfunction

function! BufferNumber()
  redraw
  let s:modified = badge#modified('+')
  let s:bufno = bufnr('%')
  if empty(s:modified)
    execute 'hi User3 ctermfg=244 ctermbg=237 guifg=#808080 guibg=#3a3a3a'
  else
    execute 'hi User3 cterm=bold ctermfg=255 ctermbg=1 guifg=#eeeeee guibg=#aa4450 gui=bold'
  endif
  return s:bufno
endfunction

function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction

" By default vista.vim never run if you don't call it explicitly.
"
" If you want to show the nearest function in your statusline automatically,
" you can add the following line to your vimrc
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()

" Status line detail:
" -------------------
"
" %f    file name
" %F    file path
" %y    file type between braces (if defined)
"
" %{v:servername}   server/session name (gvim only)
"
" %<    collapse to the left if window is to small
"
" %( %) display contents only if not empty
"
" %1*   use color preset User1 from this point on (use %0* to reset)
"
" %([%R%M]%)   read-only, modified and modifiable flags between braces
"
" %{'!'[&ff=='default_file_format']}
"        shows a '!' if the file format is not the platform default
"
" %{'$'[!&list]}  shows a '*' if in list mode
" %{'~'[&pm=='']} shows a '~' if in patchmode
"
" %=     right-align following items
"
" %{&fileencoding}  displays encoding (like utf8)
" %{&fileformat}    displays file format (unix, dos, etc..)
" %{&filetype}      displays file type (vim, python, etc..)
"
" #%n   buffer number
" %l/%L line number, total number of lines
" %p%   percentage of file
" %c%V  column number, absolute column number
" &modified         whether or not file was modified
"
" %-5.x - syntax to add 5 chars of padding to some element x
let s:stl  = " %7*%{&paste ? 'P' : ''}%*"                " Paste symbol
let s:stl .= '%4* %{FileMode()} %*'                      " Modified symbol
let s:stl .= '%3* %{BufferNumber()} %*'                  " Buffer number and edit flag
let s:stl .= '%8* %{EditMode()} %*'                      " Edit mode
let s:stl .= ' %1*%{badge#filename()}%*'                 " Filename
let s:stl .= ' %<'                                       " Truncate here
let s:stl .= '%( %{badge#branch()} %)'                  " Git branch name
let s:stl .= '%3*%( %{badge#gitstatus()} %)%*'           " Git status
let s:stl .= '%4*%( %{badge#syntax()} %)%*'              " syntax check
let s:stl .= "%5*%(%{badge#trails('WS:%s')} %)%*"        " Whitespace
let s:stl .= '%3*%{badge#indexing()}%*'                  " Indexing tags indicator
let s:stl .= '%='                                        " Align to right
let s:stl .= '%3*%(%{NearestMethodOrFunction()}%)%*  '   " Current tag
let s:stl .= '%{badge#format()} %*'                      " File format
let s:stl .= '%( %{&fenc} %)'                            " File encoding
let s:stl .= '%*%( %{&ft} %)'                            " File type
let s:stl .= '%2* %l/%2c%4p%% '                          " Line and column

" Non-active Statusline {{{
let s:stl_nc  = "  %{badge#mode('R', 'Z')}%n"            " Readonly & buffer
let s:stl_nc .= "%5*%{badge#modified('+')}%*"            " Write symbol
let s:stl_nc .= ' %{badge#filename()}'                   " Relative supername
let s:stl_nc .= '%='                                     " Align to right
let s:stl_nc .= '%{&ft} '                                " File type
" }}}

let s:disable_statusline =
  \ 'denite\|vista\|vimfiler\|undotree\|gundo\|diff\|peekaboo\|sidemenu'

" Toggle Statusline {{{
function! s:refresh()
  if &filetype ==# 'defx'
    let &l:statusline = '%y %<%=%{badge#filename()}%= %l/%L'
  elseif &filetype ==# 'magit'
    let &l:statusline = '%y %{badge#gitstatus()}%<%=%{badge#filename()}%= %l/%L'
  elseif &filetype !~# s:disable_statusline
    let &l:statusline = s:stl
  endif
endfunction

function! s:refresh_inactive()
  if &filetype ==# 'defx'
    let &l:statusline = '%y %= %l/%L'
  elseif &filetype ==# 'magit'
    let &l:statusline = '%y %{badge#gitstatus()}%= %l/%L'
  elseif &filetype !~# s:disable_statusline
    let &l:statusline = s:stl_nc
  endif
endfunction

augroup user_statusline
  autocmd!

  autocmd FileType,WinEnter,BufWinEnter,BufReadPost * call s:refresh()
  autocmd WinLeave * call s:refresh_inactive()
  autocmd BufNewFile,ShellCmdPost,BufWritePost * call s:refresh()
  autocmd FileChangedShellPost,ColorScheme * call s:refresh()
  " autocmd FileReadPre,ShellCmdPost,FileWritePost * call s:refresh()
  autocmd User CocStatusChange,CocGitStatusChange call s:refresh()
  autocmd User CocDiagnosticChange call s:refresh()
  autocmd User GutentagsUpdating call s:refresh()
augroup END
" }}}
