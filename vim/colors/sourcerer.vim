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
" adjuested by yusiwen@gmail.com
"
" put this file in: ~/.vim/colors/
"   or make linke `ln -sf ~/myConfigs/vim/colors ~/.vim/colors`

set background=dark
hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "sourcerer"

hi Normal               cterm=NONE      ctermbg=NONE ctermfg=145  guifg=#c2c2b0 guibg=#222222 gui=NONE
hi ColorColumn          cterm=NONE      ctermbg=16   ctermfg=NONE guifg=NONE    guibg=#1c1c1c
hi Conceal              cterm=NONE      ctermbg=248  ctermfg=252
hi Cursor               cterm=NONE      ctermbg=241  ctermfg=fg   guifg=NONE    guibg=#626262 gui=NONE
hi CursorColumn         cterm=NONE      ctermbg=16   ctermfg=fg   guibg=#2d2d2d
hi CursorLine           cterm=NONE      ctermbg=236  ctermfg=fg   guibg=#2d2d2d
hi InsertModeCursorLine cterm=NONE      ctermbg=16   ctermfg=fg
hi NormalModeCursorLine cterm=NONE      ctermbg=235  ctermfg=fg
hi DiffAdd              cterm=NONE      ctermbg=71   ctermfg=16   guifg=#000000 guibg=#3cb371 gui=NONE
hi DiffDelete           cterm=NONE      ctermbg=124  ctermfg=16   guifg=#000000 guibg=#aa4450 gui=NONE
hi DiffChange           cterm=NONE      ctermbg=68   ctermfg=16   guifg=#000000 guibg=#4f94cd gui=NONE
hi DiffText             cterm=NONE      ctermbg=117  ctermfg=16   guifg=#000000 guibg=#8ee5ee gui=NONE
hi Directory            cterm=bold      ctermbg=NONE ctermfg=33   guifg=#1e90ff guibg=NONE    gui=bold
hi ErrorMsg             cterm=bold      ctermbg=NONE ctermfg=203  guifg=#ff6a6a guibg=NONE    gui=bold
hi FoldColumn           cterm=bold      ctermbg=239  ctermfg=243  guifg=#68838b guibg=#4B4B4B gui=bold
hi Folded               cterm=NONE      ctermbg=239  ctermfg=fg   guifg=#406060 guibg=#232c2c gui=NONE
hi IncSearch            cterm=bold      ctermbg=202  ctermfg=231  guifg=#ffffff guibg=#ff4500 gui=bold
hi LineNr               cterm=NONE      ctermbg=237  ctermfg=102  guifg=#878787 guibg=#3A3A3A gui=NONE
hi MatchParen           cterm=bold      ctermbg=NONE ctermfg=226  guifg=#fff000 guibg=NONE    gui=bold
hi ModeMsg              cterm=bold      ctermbg=NONE ctermfg=145  guifg=#afafaf guibg=#222222 gui=bold
hi MoreMsg              cterm=bold      ctermbg=NONE ctermfg=29   guifg=#2e8b57 guibg=NONE    gui=bold
hi NonText              cterm=NONE      ctermbg=NONE ctermfg=237  guifg=#404050 guibg=NONE    gui=NONE
hi Pmenu                cterm=NONE      ctermbg=238  ctermfg=231  guifg=#ffffff guibg=#444444
hi PmenuSbar            cterm=NONE      ctermbg=250  ctermfg=fg   guifg=#ffffff guibg=$444444
hi PmenuSel             cterm=NONE      ctermbg=149  ctermfg=16   guifg=#000000 guibg=#b1d631
hi PmenuThumb           cterm=reverse   ctermbg=NONE ctermfg=fg
hi Question             cterm=bold      ctermbg=NONE ctermfg=46   guifg=#00ee00 guibg=NONE    gui=bold
hi Search               cterm=bold      ctermbg=11   ctermfg=16   guifg=#000000 guibg=#d6e770 gui=bold
hi SignColumn           cterm=NONE      ctermbg=NONE ctermfg=231  guifg=#ffffff guibg=NONE    gui=NONE
hi SpecialKey           cterm=NONE      ctermbg=NONE ctermfg=237  guifg=#505060 guibg=NONE    gui=NONE
hi SpellBad             cterm=underline ctermbg=NONE ctermfg=196  guisp=#ee2c2c gui=undercurl
hi SpellCap             cterm=underline ctermbg=NONE ctermfg=21   guisp=#0000ff gui=undercurl
hi SpellLocal           cterm=underline ctermbg=NONE ctermfg=30   guisp=#008b8b gui=undercurl
hi SpellRare            cterm=underline ctermbg=NONE ctermfg=201  guisp=#ff00ff gui=undercurl
hi StatusLine           cterm=bold      ctermbg=234  ctermfg=13   guifg=#000000 guibg=#808070 gui=bold
hi StatusLineNC         cterm=NONE      ctermbg=239  ctermfg=235  guifg=#000000 guibg=#404c4c gui=italic
hi StatusLineAlert      cterm=NONE      ctermbg=160  ctermfg=231
hi StatusLineUnalert    cterm=NONE      ctermbg=238  ctermfg=144
hi VertSplit            cterm=NONE      ctermbg=102  ctermfg=102  guifg=#404c4c guibg=#404c4c gui=NONE
hi TabLine              cterm=bold      ctermbg=102  ctermfg=16   guifg=fg      guibg=#d3d3d3 gui=bold
hi TabLineFill          cterm=NONE      ctermbg=102  ctermfg=16   guifg=fg      guibg=NONE    gui=NONE
hi TabLineSel           cterm=bold      ctermbg=16   ctermfg=59   guifg=fg      guibg=NONE    gui=bold
hi Title                cterm=bold      ctermbg=NONE ctermfg=66   guifg=#528b8b guibg=NONE    gui=bold
hi Visual               cterm=NONE      ctermbg=67   ctermfg=16   guifg=#000000 guibg=#6688aa gui=NONE
hi VisualNOS            cterm=bold      ctermbg=NONE ctermfg=fg
hi WarningMsg           cterm=NONE      ctermbg=NONE ctermfg=208  guifg=#ee9a00 guibg=NONE    gui=NONE
hi WildMenu             cterm=NONE      ctermbg=116  ctermfg=16   guifg=#000000 guibg=#87ceeb gui=NONE
hi ExtraWhitespace      cterm=NONE      ctermbg=66   ctermfg=fg   guifg=fg      guibg=#528b8b gui=NONE

hi Comment              cterm=italic    ctermbg=NONE ctermfg=59   guifg=#686858 gui=italic
hi Boolean              cterm=NONE      ctermbg=NONE ctermfg=208  guifg=#ff9800 gui=NONE
hi String               cterm=NONE      ctermbg=NONE ctermfg=101  guifg=#779b70 gui=NONE
hi Identifier           cterm=NONE      ctermbg=NONE ctermfg=145  guifg=#9ebac2 gui=NONE
hi Function             cterm=NONE      ctermbg=NONE ctermfg=230  guifg=#faf4c6 gui=NONE
hi Type                 cterm=bold      ctermbg=NONE ctermfg=67   guifg=#7e8aa2 gui=NONE
hi Statement            cterm=bold      ctermbg=NONE ctermfg=67   guifg=#90b0d1 gui=NONE
hi Constant             cterm=NONE      ctermbg=NONE ctermfg=208  guifg=#ff9800 gui=NONE
hi Number               cterm=NONE      ctermbg=NONE ctermfg=172  guifg=#cc8800 gui=NONE
hi Special              cterm=NONE      ctermbg=NONE ctermfg=64   guifg=#719611 gui=NONE
hi Underlined           cterm=underline ctermbg=NONE ctermfg=111
hi Error                cterm=NONE      ctermbg=196  ctermfg=231
hi Ignore               cterm=NONE      ctermbg=NONE ctermfg=234
hi PreProc              cterm=bold      ctermbg=NONE ctermfg=66   guifg=#528b8b gui=NONE
hi Todo                 cterm=bold      ctermbg=234  ctermfg=96   guifg=#8f6f8f guibg=#202020 gui=bold

hi diffOldFile          cterm=NONE      ctermbg=NONE ctermfg=67   guifg=#88afcb guibg=NONE    gui=italic
hi diffNewFile          cterm=NONE      ctermbg=NONE ctermfg=67   guifg=#88afcb guibg=NONE    gui=italic
hi diffFile             cterm=NONE      ctermbg=NONE ctermfg=67   guifg=#88afcb guibg=NONE    gui=italic
hi diffLine             cterm=NONE      ctermbg=NONE ctermfg=67   guifg=#88afcb guibg=NONE    gui=italic
hi diffAdded            cterm=NONE      ctermfg=NONE ctermfg=71   guifg=#3cb371 guibg=NONE    gui=NONE
hi diffRemoved          cterm=NONE      ctermfg=NONE ctermfg=124  guifg=#aa4450 guibg=NONE    gui=NONE
hi diffChanged          cterm=NONE      ctermfg=NONE ctermfg=68   guifg=#4f94cd guibg=NONE    gui=NONE
hi link diffSubname     diffLine
hi link diffOnly        Constant
hi link diffIdentical   Constant
hi link diffDiffer      Constant
hi link diffBDiffer     Constant
hi link diffIsA         Constant
hi link diffNoEOL       Constant
hi link diffCommon      Constant
hi link diffComment     Constant

hi pythonClass          cterm=NONE      ctermbg=NONE  ctermfg=fg
hi pythonDecorator      cterm=NONE      ctermbg=NONE  ctermfg=101
hi pythonExClass        cterm=NONE      ctermbg=NONE  ctermfg=95
hi pythonException      cterm=NONE      ctermbg=NONE  ctermfg=110
hi pythonFunc           cterm=NONE      ctermbg=NONE  ctermfg=fg
hi pythonFuncParams     cterm=NONE      ctermbg=NONE  ctermfg=fg
hi pythonKeyword        cterm=NONE      ctermbg=NONE  ctermfg=fg
hi pythonParam          cterm=NONE      ctermbg=NONE  ctermfg=fg
hi pythonRawEscape      cterm=NONE      ctermbg=NONE  ctermfg=fg
hi pythonSuperclasses   cterm=NONE      ctermbg=NONE  ctermfg=fg
hi pythonSync           cterm=NONE      ctermbg=NONE  ctermfg=fg

hi Test                 cterm=NONE      ctermbg=NONE  ctermfg=fg
hi cCursor              cterm=reverse   ctermbg=NONE  ctermfg=fg
hi iCursor              cterm=NONE      ctermbg=210   ctermfg=16
hi lCursor              cterm=NONE      ctermbg=145   ctermfg=234
hi nCursor              cterm=NONE      ctermbg=NONE  ctermfg=145
hi vCursor              cterm=NONE      ctermbg=201   ctermfg=16
