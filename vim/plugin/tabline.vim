" My Tabline
" Taken from Rafi's Tabline
" --------------------------

" Tabline {{{
function! Tabline() abort "{{{
  " Active project tab
  let s:tabline =
    \ '%#TabLineAlt# %{badge#project()} '.
    \ '%#TabLineAltShade#'.
    \ '%#TabLineFill#  '

  let l:nr = tabpagenr()
  for l:i in range(tabpagenr('$'))
    if l:i + 1 == l:nr
      " Active tab
      let s:tabline .=
        \ '%#TabLineSel# '.
        \ '%'.(l:i+1).'T'.'[%{badge#filename('.(l:i+1).', "", "N/A")}'.'] '
    else
      " Normal tab
      let s:tabline .=
        \ '%#TabLine# '.
        \ '%'.(l:i+1).'T%{badge#filename('.(l:i+1).', "", "N/A")} '
    endif
  endfor
  " Empty space and session indicator
  let s:tabline .=
    \ '%#TabLineFill#%T%=%#TabLine#' .
    \ '%{badge#session("['.fnamemodify(v:this_session, ':t:r').']")}'
  return s:tabline
endfunction "}}}

let &tabline='%!Tabline()'
" }}}
