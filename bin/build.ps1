# Build Vim(32-bit) for windows.
#
# Reference:
# src/INSTALLpc.txt, src/Make_mvc.mak
#
# Requirements:
# Visual Studio, Git or Mercurial, 7-zip, Python27, Python33, Ruby, Luajit

# You should compile ruby from source as the binary from "rubyinstaller.org" is built on mingw.
#
# Author: Bohr Shaw (mailto:pubohr@gmail.com)
# License: Distributes under the same terms as vim

# Environments {{{1
# Import visual studio environment variables
pushd 'C:\Program Files\Microsoft Visual Studio 12.0\VC'
cmd /c "vcvarsall.bat&set" |
foreach {
  if ($_ -match "=") {
    $v = $_.split("="); Set-Content -force -path "ENV:\$($v[0])"  -value "$($v[1])"
  }
}
popd

$vim = "vim" # the directory name of Vim's source
$python = "C:\Python27"
$python3 = "C:\Python33"
$ruby = "D:\Programs\Ruby20"
$lua = "D:\Workspaces\builds\luajit\src"

# Source Code {{{1
if((git config --get-regex remote.*url) -match '.*b4winckler/vim.*') {
  nmake clean
  git reset --hard; git clean -dxfq
  git pull
}
elseif((hg paths default) -match '.*vim.*') {
  nmake clean
  hg pull; hg update -C; hg purge --all
}
else {
  git clone --depth 1 git://github.com/b4winckler/vim.git $vim
  cd $vim
}

# Building {{{1
pushd src

# Gvim
nmake -f Make_mvc.mak `
  SDK_INCLUDE_DIR="C:\Program Files\Microsoft SDKs\Windows\v7.1A\Include" `
  CPUNR=i686 WINVER=0x0500 `
  FEATURES=HUGE GUI=yes OLE=no MBYTE=yes IME=yes `
  PYTHON=$python DYNAMIC_PYTHON=yes PYTHON_VER=27 `
  PYTHON3=$python3 DYNAMIC_PYTHON3=yes PYTHON3_VER=33 `
  RUBY=$ruby DYNAMIC_RUBY=yes RUBY_VER=20 RUBY_VER_LONG=2.0.0 RUBY_PLATFORM=i386-mswin32_120 RUBY_INSTALL_NAME=msvcr120-ruby200 `
  LUA=$lua DYNAMIC_LUA=yes LUA_VER=51 `
  USERNAME=bohrshaw USERDOMAIN=gmail.com

# Vim
nmake -f Make_mvc.mak `
  SDK_INCLUDE_DIR="C:\Program Files\Microsoft SDKs\Windows\v7.1A\Include" `
  CPUNR=i686 WINVER=0x0500 `
  FEATURES=BIG MBYTE=yes `
  PYTHON3=$python3 DYNAMIC_PYTHON3=yes PYTHON3_VER=33 `
  USERNAME=bohrshaw USERDOMAIN=gmail.com

popd

# Packaging {{{1
cp src\*.exe,src\*.dll,src\xxd\xxd.exe,vimtutor.bat,README.txt,$lua\*.dll runtime
mkdir runtime\GvimExt 2>$null
(ls .\src\GvimExt) -match '.*\.(dll|bat|inf|reg|txt)$' | cp -Destination .\runtime\GvimExt
mkdir runtime\VisVim 2>$null
(ls .\src\VisVim) -match '.*\.(dll|bat|inf|reg|txt)$' | cp -Destination .\runtime\VisVim

mkdir Vim; mv runtime Vim\vim74
& 7z a -mx=9 vim-bohr.7z Vim
mv Vim\vim74 runtime; rmdir Vim

# vim:tw=0 ts=2 sw=2 et fdm=marker:
