" Neovim-qt GUI settings

if BundleRun('equalsraf/neovim-gui-shim')
  call GuiWindowMaximized(1)
  command! FullScreen execute g:GuiWindowFullScreen ?
        \ GuiWindowFullScreen(0)[9] : GuiWindowFullScreen(1)[9]
  GuiFont Consolas:h10
endif
