if has('win32') || has('win64')
    set guifont=Consolas:h10
    au GUIEnter * simalt ~x " max window
else
    set guifont=Consolas\ 10
    set lines=999 columns=999
endif

set guioptions=
color solarized
