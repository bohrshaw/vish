# Build vim 32-bit version for windows.
# You should better run this script from an empty directory.
#
# Reference:
# INSTALLpc.txt, Make_mvc.mak
#
# Requirements:
# Visual Studio 2012, Git, 7z
# Python-27, Python-33, Ruby win32 version
# (You may compile ruby from source as the binary from "rubyinstaller.org" is built on mingw.)
#
# Author: Bohr Shaw (mailto:pubohr@gmail.com)
# License: Distributes under the same terms as vim

# Set environment variables {{{1
# Import visual studio environment variables
pushd 'c:\Program Files\Microsoft Visual Studio 11.0\VC'
cmd /c "vcvarsall.bat&set" |
foreach {
  if ($_ -match "=") {
    $v = $_.split("="); Set-Content -force -path "ENV:\$($v[0])"  -value "$($v[1])"
  }
}
popd

$vim_src = "vim-src" # the directory name of Vim's source
$python_src = "C:\Python27"
$python3_src = "C:\Python33"
$ruby_src = "C:\ruby200-mswin32"
$lua_src = [System.IO.Path]::GetFullPath((Join-Path (pwd) "..\luajit-src\src"))

# Prepare the source {{{1
# Vim
if((git config --get-regex remote.*url) -match '.*b4winckler/vim.*') {
  nmake clean
  git reset --hard; git clean -dxfq
  git pull
}else {
  git clone --depth 1 git://github.com/b4winckler/vim.git $vim_src
  cd $vim_src
}

# Luajit
if(!(Test-Path $lua_src)) {
  git clone http://luajit.org/git/luajit-2.0.git $lua_src.TrimEnd('src').TrimEnd('\')
  pushd $lua_src
  .\msvcbuild.bat
  popd
}

# Compile {{{1
pushd src

# Vim
nmake -f Make_mvc.mak `
  SDK_INCLUDE_DIR="C:\Program Files\Microsoft SDKs\Windows\v7.1A\Include" `
  USERNAME=bohrshaw `
  USERDOMAIN=gmail.com `
  CPUNR=i686 WINVER=0x0600 `
  FEATURES=BIG `
  MBYTE=yes IME=yes `
  PYTHON=$python_src DYNAMIC_PYTHON=yes PYTHON_VER=27 `
  PYTHON3=$python3_src DYNAMIC_PYTHON3=yes PYTHON3_VER=33

# Gvim
nmake -f Make_mvc.mak `
  SDK_INCLUDE_DIR="C:\Program Files\Microsoft SDKs\Windows\v7.1A\Include" `
  USERNAME=bohrshaw `
  USERDOMAIN=gmail.com `
  CPUNR=i686 WINVER=0x0600 `
  FEATURES=HUGE `
  GUI=yes OLE=yes MBYTE=yes IME=yes `
  PYTHON=$python_src DYNAMIC_PYTHON=yes PYTHON_VER=27 `
  PYTHON3=$python3_src DYNAMIC_PYTHON3=yes PYTHON3_VER=33 `
  RUBY=$ruby_src DYNAMIC_RUBY=yes RUBY_VER=20 RUBY_VER_LONG=2.0.0 RUBY_API_VER=200 RUBY_PLATFORM=i386-mswin32_110 `
  LUA=$lua_src DYNAMIC_LUA=yes LUA_VER=51

popd

# Package {{{1
git ls-files -o src | ? { $_ -match '.*\.(exe|dll)$' } | cp -Destination runtime

mkdir vim
mv runtime vim\vim74

& 7z a vim-bohr.7z vim

mv vim\vim74 runtime
rmdir vim

# vim:tw=0 ts=2 sw=2 et fdm=marker:
