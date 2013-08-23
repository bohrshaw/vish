" Name:    Terminater vim colorscheme
" Author:  Bohr Shaw <pubohr@gmail.com>
" URL:
" License:
"
" Note:
" To see available terminal colors visually:
" Run 'bin/color-show.sh'
" To see highlighting groups for various occasions:
" :so $VIMRUNTIME/syntax/hitest.vim

" Colorscheme initialization {{{1
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "terminater"

set background=dark

" Terminal color definitions {{{1
let s:t00 = "00"
let s:t01 = "0"
let s:t02 = "11"
let s:t03 = "08"
let s:t04 = "12"
let s:t05 = "07"
let s:t06 = "13"
let s:t07 = "15"
let s:t08 = "01"
let s:t09 = "09"
let s:t0A = "03"
let s:t0B = "02"
let s:t0C = "06"
let s:t0D = "06"
let s:t0E = "05"
let s:t0F = "14"
let s:darklight = 235

" Highlighting function {{{1
fun <sid>hi(group, ctermfg, ctermbg, attr)
  if a:ctermfg != ""
    exec "hi " . a:group . " ctermfg=" . a:ctermfg
  endif
  if a:ctermbg != ""
    exec "hi " . a:group . " ctermbg=" . a:ctermbg
  endif
  if a:attr != ""
    exec "hi " . a:group . " cterm=" . a:attr
  endif
endfun

" Vim editor highlighting {{{1
call <sid>hi("Bold",          "", "", "bold")
call <sid>hi("Debug",         s:t08, "", "")
call <sid>hi("Directory",     s:t0D, "", "")
call <sid>hi("ErrorMsg",      s:t08, "none", "")
call <sid>hi("Exception",     s:t08, "", "")
call <sid>hi("FoldColumn",    "", "", "")
call <sid>hi("Folded",        s:t03, s:darklight, "")
call <sid>hi("IncSearch",     s:t0A, "", "")
call <sid>hi("Italic",        "", "", "none")
call <sid>hi("Macro",         s:t08, "", "")
call <sid>hi("MatchParen",    s:t03, "",  "reverse")
call <sid>hi("ModeMsg",       s:t0B, "", "")
call <sid>hi("MoreMsg",       s:t0B, "", "")
call <sid>hi("Question",      s:t0A, "", "")
call <sid>hi("Search",        s:t0A, "",  "reverse")
call <sid>hi("SpecialKey",    s:t03, "", "")
call <sid>hi("TooLong",       s:t08, "", "")
call <sid>hi("Underlined",    s:t08, "", "")
call <sid>hi("Visual",        "", s:darklight, "")
call <sid>hi("VisualNOS",     s:t08, "", "")
call <sid>hi("WarningMsg",    s:t08, "", "")
call <sid>hi("WildMenu",      s:t08, "", "")
call <sid>hi("Title",         s:t0D, "", "none")
call <sid>hi("Conceal",       s:t0D, "", "")
call <sid>hi("Cursor",        s:t00, "", "")
call <sid>hi("NonText",       s:t03, "", "")
call <sid>hi("Normal",        s:t05, "", "")
call <sid>hi("LineNr",        s:t03, "", "")
call <sid>hi("SignColumn",    s:t03, s:darklight, "")
call <sid>hi("SpecialKey",    s:t03, "", "")
call <sid>hi("StatusLine",    s:t04, "", "none")
call <sid>hi("StatusLineNC",  s:t03, "", "none")
call <sid>hi("VertSplit",     s:t02, "", "none")
call <sid>hi("ColorColumn",   "", "", "none")
call <sid>hi("CursorColumn",  "", "", "none")
call <sid>hi("CursorLine",    "", "", "none")
call <sid>hi("CursorLineNr",  s:t03, "", "")
call <sid>hi("PMenu",         s:t04, "", "none")
call <sid>hi("PMenuSel",      s:t04, "", "reverse")
call <sid>hi("TabLine",       s:t03, "", "none")
call <sid>hi("TabLineFill",   s:t03, "", "none")
call <sid>hi("TabLineSel",    s:t0B, "", "none")

" Standard syntax highlighting {{{1
call <sid>hi("Boolean",      s:t09, "", "")
call <sid>hi("Character",    s:t08, "", "")
call <sid>hi("Comment",      s:t03, "", "")
call <sid>hi("Conditional",  s:t0E, "", "")
call <sid>hi("Constant",     s:t09, "", "")
call <sid>hi("Define",       s:t0E, "", "none")
call <sid>hi("Delimiter",    s:t0F, "", "")
call <sid>hi("Float",        s:t09, "", "")
call <sid>hi("Function",     s:t0D, "", "")
call <sid>hi("Identifier",   s:t08, "", "none")
call <sid>hi("Include",      s:t0D, "", "")
call <sid>hi("Keyword",      s:t0E, "", "")
call <sid>hi("Label",        s:t0A, "", "")
call <sid>hi("Number",       s:t09, "", "")
call <sid>hi("Operator",     s:t05, "", "none")
call <sid>hi("PreProc",      s:t0A, "", "")
call <sid>hi("Repeat",       s:t0A, "", "")
call <sid>hi("Special",      s:t0C, "", "")
call <sid>hi("SpecialChar",  s:t0F, "", "")
call <sid>hi("Statement",    s:t08, "", "")
call <sid>hi("StorageClass", s:t0A, "", "")
call <sid>hi("String",       s:t0B, "", "")
call <sid>hi("Structure",    s:t0E, "", "")
call <sid>hi("Tag",          s:t0A, "", "")
call <sid>hi("Todo",         s:t0A, "", "")
call <sid>hi("Type",         s:t09, "", "none")
call <sid>hi("Typedef",      s:t0A, "", "")

" Spelling highlighting {{{1
call <sid>hi("SpellBad",     "", "none", "undercurl")
call <sid>hi("SpellLocal",   "", "none", "undercurl")
call <sid>hi("SpellCap",     "", "none", "undercurl")
call <sid>hi("SpellRare",    "", "none", "undercurl")

" Diff highlighting {{{1
call <sid>hi("DiffAdd",      s:t0B, s:darklight, "")
call <sid>hi("DiffChange",   s:t0D, s:darklight, "")
call <sid>hi("DiffDelete",   s:t08, s:darklight, "")
call <sid>hi("DiffText",     s:t0D, "", "")
call <sid>hi("DiffAdded",    s:t0B, "", "")
call <sid>hi("DiffFile",     s:t08, "", "")
call <sid>hi("DiffNewFile",  s:t0B, "", "")
call <sid>hi("DiffLine",     s:t0D, "", "")
call <sid>hi("DiffRemoved",  s:t08, "", "")

" Ruby highlighting {{{1
call <sid>hi("rubyAttribute",               s:t0D, "", "")
call <sid>hi("rubyConstant",                s:t0A, "", "")
call <sid>hi("rubyInterpolation",           s:t0B, "", "")
call <sid>hi("rubyInterpolationDelimiter",  s:t0F, "", "")
call <sid>hi("rubyRegexp",                  s:t0C, "", "")
call <sid>hi("rubySymbol",                  s:t0B, "", "")
call <sid>hi("rubyStringDelimiter",         s:t0B, "", "")

" HTML highlighting {{{1
call <sid>hi("htmlBold",    s:t0A, "", "")
call <sid>hi("htmlItalic",  s:t0E, "", "")
call <sid>hi("htmlEndTag",  s:t05, "", "")
call <sid>hi("htmlTag",     s:t05, "", "")

" CSS highlighting {{{1
call <sid>hi("cssBraces",      s:t05, "", "")
call <sid>hi("cssClassName",   s:t0E, "", "")
call <sid>hi("cssColor",       s:t0C, "", "")

" SASS highlighting {{{1
call <sid>hi("sassidChar",     s:t08, "", "")
call <sid>hi("sassClassChar",  s:t09, "", "")
call <sid>hi("sassInclude",    s:t0E, "", "")
call <sid>hi("sassMixing",     s:t0E, "", "")
call <sid>hi("sassMixinName",  s:t0D, "", "")

" JavaScript highlighting {{{1
call <sid>hi("javaScript",        s:t05, "", "")
call <sid>hi("javaScriptBraces",  s:t05, "", "")
call <sid>hi("javaScriptNumber",  s:t09, "", "")

" Markdown highlighting {{{1
call <sid>hi("markdownCode",              s:t0B, "", "")
call <sid>hi("markdownCodeBlock",         s:t0B, "", "")
call <sid>hi("markdownHeadingDelimiter",  s:t0D, "", "")

" Git highlighting {{{1
call <sid>hi("gitCommitOverflow",  s:t08, "", "")
call <sid>hi("gitCommitSummary",   s:t0B, "", "")

" __Footer__ {{{1
" vim:fdm=marker:
