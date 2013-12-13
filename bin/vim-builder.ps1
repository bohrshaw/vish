# Build Vim(32-bit) for windows.
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
$ruby = "D:\Programs\Ruby"
$lua = "D:\Workspaces\srcs\luajit\src"

# Prepare Vim source {{{1
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
  PYTHON3=$python3 DYNAMIC_PYTHON3=yes PYTHON3_VER=33

# Gvim
nmake -f Make_mvc.mak `
  SDK_INCLUDE_DIR="C:\Program Files\Microsoft SDKs\Windows\v7.1A\Include" `
  USERNAME=bohrshaw `
  USERDOMAIN=gmail.com `
  CPUNR=i686 WINVER=0x0600 `
  FEATURES=HUGE `
  GUI=yes MBYTE=yes IME=yes `
  PYTHON=$python DYNAMIC_PYTHON=yes PYTHON_VER=27 `
  PYTHON3=$python3 DYNAMIC_PYTHON3=yes PYTHON3_VER=33 `
  RUBY=$ruby DYNAMIC_RUBY=yes RUBY_VER=20 RUBY_VER_LONG=2.0.0 RUBY_API_VER=2.0.0 RUBY_PLATFORM=i386-mswin32_120 `
  LUA=$lua DYNAMIC_LUA=yes LUA_VER=51

popd

# Package {{{1
ls -r src | ? { $_ -match '.*\.(exe|dll)$' } | cp -Destination runtime
cp $lua\*.dll runtime

mkdir vim
mv runtime vim\vim74

& 7z a vim-bohr.7z vim

mv vim\vim74 runtime
rmdir vim

# vim:tw=0 ts=2 sw=2 et fdm=marker:
