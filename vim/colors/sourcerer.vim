"   ██████  ██████  ██   ██ ██████  █████   █████  ██████  █████  ██████
"  ██░░░░  ██░░░░██░██  ░██░░██░░████░░░██ ██░░░██░░██░░████░░░██░░██░░██
" ░░█████ ░██   ░██░██  ░██ ░██ ░░░██  ░░ ░███████ ░██ ░░░███████ ░██ ░░
"  ░░░░░██░██   ░██░██  ░██ ░██   ░██   ██░██░░░░  ░██   ░██░░░░  ░██
"  ██████ ░░██████ ░░██████░███   ░░█████ ░░██████░███   ░░██████░███
" ░░░░░░   ░░░░░░   ░░░░░░ ░░░     ░░░░░   ░░░░░░ ░░░     ░░░░░░ ░░░
"  r  e  a  d     c  o  d  e     l  i  k  e     a     w  i  z  a  r  d
"
" sourcerer by xero harrison (http://xero.nu)
"  ├─ based on sorcerer by Jeet Sukumaran (http://jeetworks.org)
"  └─ based on mustang by Henrique C. Alves (hcarvalhoalves@gmail.com)
" adjusted by yusiwen@gmail.com
"
" put this file in: ~/.vim/colors/
"   or make linke `ln -sf ~/myConfigs/vim/colors ~/.vim/colors`

scriptencoding=utf-8
set background=dark
hi clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'sourcerer'

hi Normal               cterm=NONE      ctermfg=145  ctermbg=NONE guifg=#777777 guibg=#222222 gui=NONE
hi ColorColumn          cterm=NONE      ctermfg=NONE ctermbg=16   guifg=NONE    guibg=#000000 gui=NONE
hi Conceal              cterm=NONE      ctermfg=252  ctermbg=248  guifg=#8a8a8a guibg=#727272 gui=NONE
hi Cursor               cterm=NONE      ctermfg=fg   ctermbg=241  guifg=fg      guibg=#484848 gui=NONE
hi CursorColumn         cterm=NONE      ctermfg=fg   ctermbg=16   guifg=fg      guibg=#000000 gui=NONE
hi CursorLine           cterm=NONE      ctermfg=fg   ctermbg=236  guifg=fg      guibg=#2a2a2a gui=NONE
hi InsertModeCursorLine cterm=NONE      ctermfg=fg   ctermbg=16   guifg=fg      guibg=#000000 gui=NONE
hi NormalModeCursorLine cterm=NONE      ctermfg=fg   ctermbg=235  guifg=fg      guibg=#242424 gui=NONE
hi DiffAdd              cterm=NONE      ctermfg=16   ctermbg=71   guifg=#000000 guibg=#467746 gui=NONE
hi DiffDelete           cterm=NONE      ctermfg=16   ctermbg=124  guifg=#000000 guibg=#770d0d gui=NONE
hi DiffChange           cterm=NONE      ctermfg=16   ctermbg=68   guifg=#000000 guibg=#465e8f gui=NONE
hi DiffText             cterm=NONE      ctermfg=16   ctermbg=117  guifg=#000000 guibg=#5e8fa7 gui=NONE
hi Directory            cterm=bold      ctermfg=67   ctermbg=NONE guifg=#5f87af guibg=NONE    gui=bold
hi ErrorMsg             cterm=bold      ctermfg=203  ctermbg=NONE guifg=#a74646 guibg=NONE    gui=bold
hi FoldColumn           cterm=bold      ctermfg=243  ctermbg=239  guifg=#545454 guibg=#3c3c3c gui=bold
hi Folded               cterm=NONE      ctermfg=fg   ctermbg=239  guifg=fg      guibg=#3c3c3c gui=NONE
hi IncSearch            cterm=bold      ctermfg=231  ctermbg=202  guifg=#a7a7a7 guibg=#a7460d gui=bold
hi LineNr               cterm=NONE      ctermfg=102  ctermbg=237  guifg=#5e5e5e guibg=#303030 gui=NONE
hi MatchParen           cterm=bold      ctermfg=226  ctermbg=NONE guifg=#a7a70d guibg=NONE    gui=bold
hi ModeMsg              cterm=bold      ctermfg=145  ctermbg=NONE guifg=#777777 guibg=NONE    gui=bold
hi MoreMsg              cterm=bold      ctermfg=29   ctermbg=NONE guifg=#00875f guibg=NONE    gui=bold
hi NonText              cterm=NONE      ctermfg=237  ctermbg=NONE guifg=#303030 guibg=NONE    gui=NONE
hi Pmenu                cterm=NONE      ctermfg=231  ctermbg=238  guifg=#a7a7a7 guibg=#363636 gui=NONE
hi PmenuSbar            cterm=NONE      ctermfg=fg   ctermbg=250  guifg=fg      guibg=#7e7e7e gui=NONE
hi PmenuSel             cterm=NONE      ctermfg=16   ctermbg=149  guifg=#000000 guibg=#778f46 gui=NONE
hi PmenuThumb           cterm=reverse   ctermfg=fg   ctermbg=NONE guifg=fg      guibg=NONE    gui=reverse
hi Question             cterm=bold      ctermfg=46   ctermbg=NONE guifg=#0da70d guibg=NONE    gui=bold
hi Search               cterm=bold      ctermfg=16   ctermbg=11   guifg=#000000 guibg=#ff9800 gui=bold
hi SignColumn           cterm=NONE      ctermfg=231  ctermbg=NONE guifg=#a7a7a7 guibg=NONE    gui=NONE
hi SpecialKey           cterm=NONE      ctermfg=237  ctermbg=NONE guifg=#303030 guibg=NONE    gui=NONE
hi SpellBad             cterm=underline ctermfg=196  ctermbg=NONE guifg=NONE    guibg=NONE    gui=undercurl guisp=#ee2c2c
hi SpellCap             cterm=underline ctermfg=21   ctermbg=NONE guifg=NONE    guibg=NONE    gui=undercurl guisp=#0000ff
hi SpellLocal           cterm=underline ctermfg=30   ctermbg=NONE guifg=NONE    guibg=NONE    gui=undercurl guisp=#008b8b
hi SpellRare            cterm=underline ctermfg=201  ctermbg=NONE guifg=NONE    guibg=NONE    gui=undercurl guisp=#ff00ff
hi StatusLine           cterm=bold      ctermfg=13   ctermbg=237  guifg=#8181a6 guibg=#3a3a3a gui=bold
hi StatusLineNC         cterm=NONE      ctermfg=238  ctermbg=234  guifg=#444444 guibg=#1c1c1c gui=italic
hi StatusLineAlert      cterm=NONE      ctermfg=231  ctermbg=1    guifg=#ffffff guibg=#aa4450 gui=NONE
hi StatusLineUnalert    cterm=NONE      ctermfg=244  ctermbg=237  guifg=#808080 guibg=#3a3a3a gui=NONE
hi TabLine              cterm=bold      ctermfg=244  ctermbg=239  guifg=#808080 guibg=#4e4e4e gui=bold
hi TabLineFill          cterm=NONE      ctermfg=13   ctermbg=237  guifg=#8181a6 guibg=#3a3a3a gui=NONE
hi TabLineSel           cterm=bold      ctermfg=255  ctermbg=13   guifg=#eeeeee guibg=#8181a6 gui=bold
hi TabLineSelShade      cterm=NONE      ctermfg=235  ctermbg=13   guifg=#262626 guibg=#8181a6
hi TabLineAlt           cterm=NONE      ctermfg=252  ctermbg=238  guifg=#D0D0D0 guibg=#444444
hi TabLineAltShade      cterm=NONE      ctermfg=238  ctermbg=236  guifg=#444444 guibg=#303030
hi Title                cterm=bold      ctermfg=66   ctermbg=NONE guifg=#5f8787 guibg=NONE    gui=bold
hi User1                cterm=NONE      ctermfg=253  ctermbg=237  guifg=#dadada guibg=#3a3a3a
hi User2                cterm=NONE      ctermfg=248  ctermbg=239  guifg=#a8a8a8 guibg=#4e4e4e
hi User3                cterm=NONE      ctermfg=239  ctermbg=236  guifg=#4e4e4e guibg=#303030
hi User4                cterm=NONE      ctermfg=242  ctermbg=235  guifg=#6c6c6c guibg=#262626
hi User5                cterm=bold      ctermfg=1    ctermbg=237  guifg=#aa4450 guibg=#3a3a3a gui=bold
hi User6                cterm=NONE      ctermfg=167  ctermbg=235  guifg=#d75f5f guibg=#262626
hi User7                cterm=NONE      ctermfg=118  ctermbg=235  guifg=#87ff00 guibg=#262626
hi User8                cterm=NONE      ctermfg=248  ctermbg=235  guifg=#a8a8a8 guibg=#262626
hi VertSplit            cterm=NONE      ctermfg=241  ctermbg=241  guifg=#626262 guibg=#626262 gui=NONE
hi Visual               cterm=NONE      ctermfg=16   ctermbg=67   guifg=#000000 guibg=#5f87af gui=NONE
hi VisualNOS            cterm=bold      ctermfg=fg   ctermbg=NONE guifg=fg      guibg=NONE    gui=bold
hi WarningMsg           cterm=NONE      ctermfg=208  ctermbg=NONE guifg=#ff8700 guibg=NONE    gui=NONE
hi WildMenu             cterm=NONE      ctermfg=16   ctermbg=116  guifg=#000000 guibg=#87d7d7 gui=NONE
hi ExtraWhitespace      cterm=NONE      ctermfg=fg   ctermbg=66   guifg=fg      guibg=#5f8787 gui=NONE

hi Comment              cterm=italic    ctermfg=59   ctermbg=NONE guifg=#686858 gui=italic
hi Boolean              cterm=NONE      ctermfg=208  ctermbg=NONE guifg=#ff9800 gui=NONE
hi String               cterm=NONE      ctermfg=101  ctermbg=NONE guifg=#779b70 gui=NONE
hi Identifier           cterm=NONE      ctermfg=145  ctermbg=NONE guifg=#9ebac2 gui=NONE
hi Function             cterm=NONE      ctermfg=230  ctermbg=NONE guifg=#faf4c6 gui=NONE
hi Type                 cterm=bold      ctermfg=67   ctermbg=NONE guifg=#7e8aa2 gui=NONE
hi Statement            cterm=bold      ctermfg=67   ctermbg=NONE guifg=#90b0d1 gui=NONE
hi Constant             cterm=NONE      ctermfg=208  ctermbg=NONE guifg=#ff9800 gui=NONE
hi Number               cterm=NONE      ctermfg=172  ctermbg=NONE guifg=#cc8800 gui=NONE
hi Special              cterm=NONE      ctermfg=64   ctermbg=NONE guifg=#719611 gui=NONE
hi Underlined           cterm=underline ctermfg=111  ctermbg=NONE
hi Error                cterm=NONE      ctermfg=231  ctermbg=196
hi Ignore               cterm=NONE      ctermfg=234  ctermbg=NONE
hi PreProc              cterm=bold      ctermfg=66   ctermbg=NONE guifg=#528b8b gui=NONE
hi Todo                 cterm=bold      ctermfg=96   ctermbg=NONE guifg=#8f6f8f guibg=NONE    gui=bold

hi diffOldFile          cterm=NONE      ctermfg=67   ctermbg=NONE guifg=#88afcb guibg=NONE    gui=italic
hi diffNewFile          cterm=NONE      ctermfg=67   ctermbg=NONE guifg=#88afcb guibg=NONE    gui=italic
hi diffFile             cterm=NONE      ctermfg=67   ctermbg=NONE guifg=#88afcb guibg=NONE    gui=italic
hi diffLine             cterm=NONE      ctermfg=67   ctermbg=NONE guifg=#88afcb guibg=NONE    gui=italic
hi diffAdded            cterm=NONE      ctermfg=71   ctermfg=NONE guifg=#3cb371 guibg=NONE    gui=NONE
hi diffRemoved          cterm=NONE      ctermfg=124  ctermfg=NONE guifg=#aa4450 guibg=NONE    gui=NONE
hi diffChanged          cterm=NONE      ctermfg=68   ctermfg=NONE guifg=#4f94cd guibg=NONE    gui=NONE
hi link diffSubname     diffLine
hi link diffOnly        Constant
hi link diffIdentical   Constant
hi link diffDiffer      Constant
hi link diffBDiffer     Constant
hi link diffIsA         Constant
hi link diffNoEOL       Constant
hi link diffCommon      Constant
hi link diffComment     Constant

hi pythonClass          cterm=NONE      ctermfg=fg   ctermbg=NONE
hi pythonDecorator      cterm=NONE      ctermfg=101  ctermbg=NONE
hi pythonExClass        cterm=NONE      ctermfg=95   ctermbg=NONE
hi pythonException      cterm=NONE      ctermfg=110  ctermbg=NONE
hi pythonFunc           cterm=NONE      ctermfg=fg   ctermbg=NONE
hi pythonFuncParams     cterm=NONE      ctermfg=fg   ctermbg=NONE
hi pythonKeyword        cterm=NONE      ctermfg=fg   ctermbg=NONE
hi pythonParam          cterm=NONE      ctermfg=fg   ctermbg=NONE
hi pythonRawEscape      cterm=NONE      ctermfg=fg   ctermbg=NONE
hi pythonSuperclasses   cterm=NONE      ctermfg=fg   ctermbg=NONE
hi pythonSync           cterm=NONE      ctermfg=fg   ctermbg=NONE

hi Test                 cterm=NONE      ctermfg=fg   ctermbg=NONE
hi cCursor              cterm=reverse   ctermfg=fg   ctermbg=NONE
hi iCursor              cterm=NONE      ctermfg=16   ctermbg=210
hi lCursor              cterm=NONE      ctermfg=234  ctermbg=145
hi nCursor              cterm=NONE      ctermfg=145  ctermbg=NONE
hi vCursor              cterm=NONE      ctermfg=16   ctermbg=201
