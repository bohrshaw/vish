#!/usr/bin/env bash

# This script compiles and installs vim under ubuntu. Reference links:
# https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source
# http://vim.wikia.com/wiki/Building_Vim
#
# Author: Bohr Shaw <pubohr@gmail.com>
# License: Distributes under the same terms as Vim

# Preparation {{{1
# Restore the default PATH
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games

# Determine if X server(GUI) is running
pidof 'X' &>/dev/null && X_SERVER=1

# Use `apt-get build-dep vim-gnome` to check which packages are needed
sudo apt-get install -y python python-dev python3 python3-dev ruby1.9.1 \
  ruby1.9.1-dev lua5.2 liblua5.2-dev mercurial
if [ $X_SERVER ]; then
  sudo apt-get install -y libncurses5-dev libgnome2-dev libgnomeui-dev \
    libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev libx11-dev \
    libxpm-dev libxt-dev
fi

# Purge system Vim (unnecessary if install to /usr/local/)
# sudo apt-get remove vim-gnome vim-nox vim-runtime vim-tiny vim-common \
#   vim-gui-common --auto-remove

# Get the source code of Vim
vim_src='vim'
if [[ $(git config --get-regex remote.*url) == *b4winckler/vim* ]]; then
  make distclean
  git reset --hard; git clean -dxfq
  git pull
elif [[ $(hg paths default) == *vim* ]]; then
  make distclean
  hg pull; hg update -C; hg purge --all
else
  # hg clone https://code.google.com/p/vim/ $vim_src
  git clone --depth 1 git://github.com/b4winckler/vim.git $vim_src
  cd $vim_src
fi

# Configure, compile and install Vim {{{1
pushd src

conf_cmd="./configure \
  --with-features=huge \
  --enable-pythoninterp \
  --enable-python3interp \
  --enable-rubyinterp \
  --enable-luainterp \
  --enable-multibyte \
  --disable-netbeans \
  --enable-fail-if-missing \
  --prefix=/usr/local \
  --with-compiledby='Bohr Shaw' \
  --quiet"
  # --with-python-config-dir= \
  # --with-python3-config-dir= \
  # --enable-perlinterp \
  # --enable-cscope \
  # --with-global-runtime=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after \

if [ $X_SERVER ]; then
  "$conf_cmd --enable-gui=gnome2"
else
  $conf_cmd
fi

make

# Install Vim (prepackaged in '.deb' with 'sudo checkinstall')
sudo make install

popd

# Set Vim as your default editor
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
sudo update-alternatives --set editor /usr/local/bin/vim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
sudo update-alternatives --set vi /usr/local/bin/vim

# vim:tw=0 ts=2 sw=2 et fdm=marker:
