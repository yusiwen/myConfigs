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

hi Normal               cterm=NONE      ctermbg=NONE ctermfg=145  guifg=#777777 guibg=#222222 gui=NONE
hi ColorColumn          cterm=NONE      ctermbg=16   ctermfg=NONE guifg=NONE    guibg=#0d0d0d gui=NONE
hi Conceal              cterm=NONE      ctermbg=248  ctermfg=252  guifg=#8a8a8a guibg=#727272 gui=NONE
hi Cursor               cterm=NONE      ctermbg=241  ctermfg=fg   guifg=fg      guibg=#484848 gui=NONE
hi CursorColumn         cterm=NONE      ctermbg=16   ctermfg=fg   guifg=fg      guibg=#0d0d0d gui=NONE
hi CursorLine           cterm=NONE      ctermbg=236  ctermfg=fg   guifg=fg      guibg=#2a2a2a gui=NONE
hi InsertModeCursorLine cterm=NONE      ctermbg=16   ctermfg=fg   guifg=fg      guibg=#0d0d0d gui=NONE
hi NormalModeCursorLine cterm=NONE      ctermbg=235  ctermfg=fg   guifg=fg      guibg=#242424 gui=NONE
hi DiffAdd              cterm=NONE      ctermbg=71   ctermfg=16   guifg=#0d0d0d guibg=#467746 gui=NONE
hi DiffDelete           cterm=NONE      ctermbg=124  ctermfg=16   guifg=#0d0d0d guibg=#770d0d gui=NONE
hi DiffChange           cterm=NONE      ctermbg=68   ctermfg=16   guifg=#0d0d0d guibg=#465e8f gui=NONE
hi DiffText             cterm=NONE      ctermbg=117  ctermfg=16   guifg=#0d0d0d guibg=#5e8fa7 gui=NONE
hi Directory            cterm=bold      ctermbg=NONE ctermfg=33   guifg=#0d5ea7 guibg=NONE    gui=bold
hi ErrorMsg             cterm=bold      ctermbg=NONE ctermfg=203  guifg=#a74646 guibg=NONE    gui=bold
hi FoldColumn           cterm=bold      ctermbg=239  ctermfg=243  guifg=#545454 guibg=#3c3c3c gui=bold
hi Folded               cterm=NONE      ctermbg=239  ctermfg=fg   guifg=fg      guibg=#3c3c3c gui=NONE
hi IncSearch            cterm=bold      ctermbg=202  ctermfg=231  guifg=#a7a7a7 guibg=#a7460d gui=bold
hi LineNr               cterm=NONE      ctermbg=237  ctermfg=102  guifg=#5e5e5e guibg=#303030 gui=NONE
hi MatchParen           cterm=bold      ctermbg=NONE ctermfg=226  guifg=#a7a70d guibg=NONE    gui=bold
hi ModeMsg              cterm=bold      ctermbg=NONE ctermfg=145  guifg=#777777 guibg=NONE    gui=bold
hi MoreMsg              cterm=bold      ctermbg=NONE ctermfg=29   guifg=#0d5e46 guibg=NONE    gui=bold
hi NonText              cterm=NONE      ctermbg=NONE ctermfg=237  guifg=#303030 guibg=NONE    gui=NONE
hi Pmenu                cterm=NONE      ctermbg=238  ctermfg=231  guifg=#a7a7a7 guibg=#363636 gui=NONE
hi PmenuSbar            cterm=NONE      ctermbg=250  ctermfg=fg   guifg=fg      guibg=#7e7e7e gui=NONE
hi PmenuSel             cterm=NONE      ctermbg=149  ctermfg=16   guifg=#0d0d0d guibg=#778f46 gui=NONE
hi PmenuThumb           cterm=reverse   ctermbg=NONE ctermfg=fg   guifg=fg      guibg=NONE    gui=reverse
hi Question             cterm=bold      ctermbg=NONE ctermfg=46   guifg=#0da70d guibg=NONE    gui=bold
hi Search               cterm=bold      ctermbg=11   ctermfg=16   guifg=#0d0d0d guibg=#a6680d gui=bold
hi SignColumn           cterm=NONE      ctermbg=NONE ctermfg=231  guifg=#a7a7a7 guibg=NONE    gui=NONE
hi SpecialKey           cterm=NONE      ctermbg=NONE ctermfg=237  guifg=#303030 guibg=NONE    gui=NONE
hi SpellBad             cterm=underline ctermbg=NONE ctermfg=196  guifg=NONE    guibg=NONE    gui=undercurl guisp=#ee2c2c
hi SpellCap             cterm=underline ctermbg=NONE ctermfg=21   guifg=NONE    guibg=NONE    gui=undercurl guisp=#0000ff
hi SpellLocal           cterm=underline ctermbg=NONE ctermfg=30   guifg=NONE    guibg=NONE    gui=undercurl guisp=#008b8b
hi SpellRare            cterm=underline ctermbg=NONE ctermfg=201  guifg=NONE    guibg=NONE    gui=undercurl guisp=#ff00ff
hi StatusLine           cterm=bold      ctermbg=234  ctermfg=13   guifg=#5b5b71 guibg=#1e1e1e gui=bold
hi StatusLineNC         cterm=NONE      ctermbg=239  ctermfg=235  guifg=#242424 guibg=#3c3c3c gui=italic
hi StatusLineAlert      cterm=NONE      ctermbg=160  ctermfg=231  guifg=#a7a7a7 guibg=#8f0d0d gui=NONE
hi StatusLineUnalert    cterm=NONE      ctermbg=238  ctermfg=144  guifg=#77775e guibg=#363636 gui=NONE
hi VertSplit            cterm=NONE      ctermbg=102  ctermfg=102  guifg=#5e5e5e guibg=#5e5e5e gui=NONE
hi TabLine              cterm=bold      ctermbg=102  ctermfg=16   guifg=#0d0d0d guibg=#5e5e5e gui=bold
hi TabLineFill          cterm=NONE      ctermbg=102  ctermfg=16   guifg=#00d0d0 guibg=#5e5e5e gui=NONE
hi TabLineSel           cterm=bold      ctermbg=16   ctermfg=59   guifg=#464646 guibg=#0d0d0d gui=bold
hi Title                cterm=bold      ctermbg=NONE ctermfg=66   guifg=#5f8787 guibg=NONE    gui=bold
hi Visual               cterm=NONE      ctermbg=67   ctermfg=16   guifg=#000000 guibg=#5f87af gui=NONE
hi VisualNOS            cterm=bold      ctermbg=NONE ctermfg=fg   guifg=fg      guibg=NONE    gui=bold
hi WarningMsg           cterm=NONE      ctermbg=NONE ctermfg=208  guifg=#ff8700 guibg=NONE    gui=NONE
hi WildMenu             cterm=NONE      ctermbg=116  ctermfg=16   guifg=#000000 guibg=#87d7d7 gui=NONE
hi ExtraWhitespace      cterm=NONE      ctermbg=66   ctermfg=fg   guifg=fg      guibg=#5f8787 gui=NONE

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

hi pythonClass          cterm=NONE      ctermbg=NONE ctermfg=fg
hi pythonDecorator      cterm=NONE      ctermbg=NONE ctermfg=101
hi pythonExClass        cterm=NONE      ctermbg=NONE ctermfg=95
hi pythonException      cterm=NONE      ctermbg=NONE ctermfg=110
hi pythonFunc           cterm=NONE      ctermbg=NONE ctermfg=fg
hi pythonFuncParams     cterm=NONE      ctermbg=NONE ctermfg=fg
hi pythonKeyword        cterm=NONE      ctermbg=NONE ctermfg=fg
hi pythonParam          cterm=NONE      ctermbg=NONE ctermfg=fg
hi pythonRawEscape      cterm=NONE      ctermbg=NONE ctermfg=fg
hi pythonSuperclasses   cterm=NONE      ctermbg=NONE ctermfg=fg
hi pythonSync           cterm=NONE      ctermbg=NONE ctermfg=fg

hi Test                 cterm=NONE      ctermbg=NONE ctermfg=fg
hi cCursor              cterm=reverse   ctermbg=NONE ctermfg=fg
hi iCursor              cterm=NONE      ctermbg=210  ctermfg=16
hi lCursor              cterm=NONE      ctermbg=145  ctermfg=234
hi nCursor              cterm=NONE      ctermbg=NONE ctermfg=145
hi vCursor              cterm=NONE      ctermbg=201  ctermfg=16
