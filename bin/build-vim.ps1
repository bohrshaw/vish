# Build Vim(32-bit) on windows.
#
# Reference:
# src/INSTALLpc.txt, src/Make_mvc.mak
#
# Similar works:
# http://tuxproject.de/projects/vim/_compile.bat.php
# http://wyw.dcweb.cn/#download
#
# Author: Bohr Shaw (mailto:pubohr@gmail.com)
# License: Distributes under the same terms as vim

# Environments {{{1
Param ( [Switch] $Proxy=$false )
if($script:Proxy) {
  $http_proxy = "http://localhost:8087"
  $https_proxy = $http_proxy
}

# Import visual studio environment variables
pushd 'C:\Program Files\Microsoft Visual Studio 12.0\VC'
cmd /c "vcvarsall.bat&set" |
foreach {
  if ($_ -match "=") {
    $v = $_.split("="); Set-Content -force -path "ENV:\$($v[0])"  -value "$($v[1])"
  }
}
popd

# Paths of langauges to be compiled into Vim
$python = "C:\Python27"
$python3 = "C:\Python34"
$ruby = "D:\Programs\Ruby22mswin" # avoid "rubyinstaller.org" and compile ruby with vs
$lua = "D:\Workspaces\builds\luajit\src"

# Source Code Preparation {{{1
if((git config --get-regex remote.*url) -match '.*vim/vim.*') {
  git clean -dxfq
  git diff-index --quiet HEAD
  if (-not $?) { git reset --hard }
  git pull
}
else {
  $vim_dir = "vim"
  git clone --depth 1 git://github.com/vim/vim $vim_dir
  cd $vim_dir
}

# Building {{{1
pushd src
nmake -f Make_mvc.mak clean`

# Gvim
nmake -f Make_mvc.mak `
  SDK_INCLUDE_DIR="C:\Program Files\Microsoft SDKs\Windows\v7.1A\Include" `
  CPUNR=i686 WINVER=0x0500 `
  FEATURES=HUGE GUI=yes DIRECTX=yes OLE=no MBYTE=yes IME=yes GIME=yes `
  PYTHON=$python DYNAMIC_PYTHON=yes PYTHON_VER=27 `
  PYTHON3=$python3 DYNAMIC_PYTHON3=yes PYTHON3_VER=34 `
  RUBY=$ruby DYNAMIC_RUBY=yes RUBY_VER=22 RUBY_VER_LONG=2.2.0 `
  LUA=$lua DYNAMIC_LUA=yes LUA_VER=51 `
  USERNAME=pubohr USERDOMAIN=gmail.com

# Vim
nmake -f Make_mvc.mak `
  SDK_INCLUDE_DIR="C:\Program Files\Microsoft SDKs\Windows\v7.1A\Include" `
  CPUNR=i686 WINVER=0x0500 `
  FEATURES=BIG MBYTE=yes `
  PYTHON3=$python3 DYNAMIC_PYTHON3=yes PYTHON3_VER=34 `
  USERNAME=pubohr USERDOMAIN=gmail.com

popd

# Installation {{{1
cp src\*.exe,src\*.dll,src\xxd\xxd.exe,vimtutor.bat,README.txt,$lua\*.dll runtime
mkdir runtime\GvimExt 2>$null
(ls .\src\GvimExt) -match '.*\.(dll|bat|inf|reg|txt)$' | cp -Destination .\runtime\GvimExt
mkdir runtime\VisVim 2>$null
(ls .\src\VisVim) -match '.*\.(dll|bat|inf|reg|txt)$' | cp -Destination .\runtime\VisVim

$dir = "D:/Programs/Vim/vim74"
mkdir $dir -ErrorAction Ignore
rm -r $dir".bak" -ErrorAction Ignore
mv $dir $dir".bak"
cp -r runtime $dir

# vim:tw=0 ts=2 sw=2 et fdm=marker:
