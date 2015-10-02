" Choose colors online: http://drpeterjones.com/colorcalc

if &background == 'dark'
  hi Normal guifg=#77A5B1
  hi Visual ctermbg=233
  hi Comment guifg=#52737B
  " hi LineNR ctermfg=146 guifg=#004C60
  hi CurSorLineNR guifg=#509CB0
else
endif
hi CursorLine cterm=NONE gui=NONE
hi VertSplit NONE
hi! link SignColumn LineNr

hi! link rubyControl Statement
hi! link rspecGroupMethods rubyControl
hi! link rspecMocks Identifier
hi! link rspecKeywords Identifier
hi! link rubyLocalVariableOrMethod Normal
hi! link rubyStringDelimiter Constant
hi! link rubyString Constant
hi! link rubyAccess Todo
hi! link rubySymbol Identifier
hi! link rubyPseudoVariable Type
hi! link rubyRailsARAssociationMethod Title
hi! link rubyRailsARValidationMethod Title
hi! link rubyRailsMethod Title
hi! link rubyDoBlock Normal

hi! link htmlTagName Type
hi! link htmlLink Include
hi! link sassMixinName Function
hi! link sassDefinition Function
hi! link sassProperty Type

hi! link javascriptFuncName Type
hi! link jsFuncCall jsFuncName
hi! link javascriptFunction Statement
hi! link javascriptThis Statement
hi! link javascriptParens Normal
hi! link jOperators javascriptStringD
hi! link jId Title
hi! link jClass Title

hi! link zshVariableDef Identifier
hi! link zshFunction Function

hi! link NERDTreeFile Constant
hi! link NERDTreeDir Identifier

hi! link CTagsModule Type
hi! link CTagsClass Type
hi! link CTagsMethod Identifier
hi! link CTagsSingleton Identifier
