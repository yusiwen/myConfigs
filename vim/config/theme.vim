" Theme
" ---

scriptencoding utf-8
execute 'source ' . expand('$VIM_PATH/themes/vimrc.theme.nord')

" Plugin: Defx icons and highlights {{{
" ---
highlight Defx_filename_3_Modified  ctermfg=1  guifg=#D370A3
highlight Defx_filename_3_Staged    ctermfg=10 guifg=#A3D572
highlight Defx_filename_3_Ignored   ctermfg=8  guifg=#404660
highlight link Defx_filename_3_root_marker Comment

highlight def link Defx_filename_3_Untracked Comment
highlight def link Defx_filename_3_Unknown Comment
highlight def link Defx_filename_3_Renamed Title
highlight def link Defx_filename_3_Unmerged Label
" highlight Defx_git_Deleted   ctermfg=13 guifg=#b294bb
" }}}
" Plugin: Neomake icons {{{
let g:neomake_error_sign = {'text': '!', 'texthl': 'ErrorMsg'}
let g:neomake_warning_sign = {'text': '!', 'texthl': 'WarningSyntax'}
let g:neomake_message_sign = {'text': '!', 'texthl': 'NeomakeMessageSign'}
let g:neomake_info_sign = {'text': '!', 'texthl': 'NeomakeInfoSign'}
"}}}
" Plugin: vim-gitgutter {{{
highlight! GitGutterAdd          ctermfg=46 ctermbg=237 guifg=#00ff00 guibg=#303030
highlight! GitGutterChange       ctermfg=3  ctermbg=237 guifg=#cc8800 guibg=#303030
highlight! GitGutterDelete       ctermfg=1  ctermbg=237 guifg=#aa4450 guibg=#303030
highlight! GitGutterChangeDelete ctermfg=1  ctermbg=237 guifg=#aa4450 guibg=#303030
" }}}
" Plugin: denite {{{
highlight! clear WildMenu
highlight! link WildMenu CursorLine
highlight! link deniteSelectedLine Type
highlight! link deniteMatchedChar Function
highlight! link deniteMatchedRange Underlined
highlight! link deniteMode Comment
highlight! link deniteSource_QuickfixPosition qfLineNr
" }}}
" Plugin: vim-operator-flashy {{{
highlight! link Flashy DiffText
" }}}
" Plugin: vim-signature {{{
highlight! SignatureMarkText    ctermfg=11 guifg=#756207 ctermbg=234 guibg=#1c1c1c
highlight! SignatureMarkerText  ctermfg=12 guifg=#4EA9D7 ctermbg=234 guibg=#1c1c1c
" }}}
" Plugin: vim-choosewin {{{
let g:choosewin_label = 'SDFJKLZXCV'
let g:choosewin_overlay_enable = 1
let g:choosewin_statusline_replace = 1
let g:choosewin_overlay_clear_multibyte = 0
let g:choosewin_blink_on_land = 0

let g:choosewin_color_label = {
  \ 'cterm': [ 236, 2 ], 'gui': [ '#555555', '#000000' ] }
let g:choosewin_color_label_current = {
  \ 'cterm': [ 234, 220 ], 'gui': [ '#333333', '#000000' ] }
let g:choosewin_color_other = {
  \ 'cterm': [ 235, 235 ], 'gui': [ '#333333' ] }
let g:choosewin_color_overlay = {
  \ 'cterm': [ 2, 10 ], 'gui': [ '#88A2A4' ] }
let g:choosewin_color_overlay_current = {
  \ 'cterm': [ 72, 64 ], 'gui': [ '#7BB292' ] }
" }}}

" vim: set foldmethod=marker ts=2 sw=0 tw=80 expandtab :
