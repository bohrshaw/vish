" Neovim-qt GUI settings

if BundleRun('equalsraf/neovim-gui-shim')
  GuiFont Consolas:h09
  call GuiWindowMaximized(1)
  command! FullScreen execute g:GuiWindowFullScreen ?
        \ GuiWindowFullScreen(0)[9] : GuiWindowFullScreen(1)[9]
endif

if has('win32') " not effective if the color is set earlier
  execute 'color' &background == 'light' ? 'gruvbox' : 'seoul256'
endif
