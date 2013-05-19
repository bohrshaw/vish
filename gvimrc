if has('win32') || has('win64')
    set guifont=Consolas:h10
    au GUIEnter * simalt ~x " max window
else
    " set guifont=Consolas\ 10
    set lines=250 columns=200
endif

set guioptions=
