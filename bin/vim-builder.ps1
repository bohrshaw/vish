# Compile vim from source under windows. Refer INSTALLpc.txt and Make_mvc.mak.
# Need to compile ruby from source because the binary from "rubyinstaller.org" is based on mingw.
# Also need to compile luajit from source, which should be simple and fast.
#
# Author: Bohr Shaw (mailto:pubohr@gmail.com)
# Copyright: Copyright (c) Bohr Shaw

# Prepare the source {{{1
if((git config --get-regex remote.*url) -match '.*b4winckler/vim.*') {
  nmake clean;
  git reset --hard; git clean -dxfq
  git pull
}else {
  git clone git://github.com/b4winckler/vim.git vim-src
  cd vim-src
}

# Configure, compile, package {{{1
pushd src
nmake -f Make_mvc.mak `
  SDK_INCLUDE_DIR="C:\Program Files\Microsoft SDKs\Windows\v7.1A\Include" `
  USERNAME=bohrshaw `
  USERDOMAIN=gmail.com `
  CPUNR=i686 WINVER=0x0500 `
  FEATURES=HUGE `
  GUI=yes OLE=yes MBYTE=yes IME=yes `
  PYTHON=C:\Python27 DYNAMIC_PYTHON=yes PYTHON_VER=27 `
  PYTHON3=C:\Python33 DYNAMIC_PYTHON3=yes PYTHON3_VER=33 `
  RUBY=C:\ruby200-mswin32 DYNAMIC_RUBY=yes RUBY_VER=20 RUBY_VER_LONG=2.0.0 RUBY_API_VER=200 RUBY_PLATFORM=i386-mswin32_110 `
  LUA=D:\projects\srcs\luajit-src\src DYNAMIC_LUA=yes LUA_VER=51
popd

cp src\*.exe runtime

mkdir vim; mv runtime vim
& 7z a vim-bohr.7z vim
mv vim\runtime; rmdir vim
# }}}1

# vim:tw=0 ts=2 sw=2 et fdm=marker fdl=1:
