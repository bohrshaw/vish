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
pidof 'X' &>/dev/null && X=1

# sudo apt-get install -y python python-dev python3 python3-dev ruby1.9.1 \
#   ruby1.9.1-dev lua5.2 liblua5.2-dev mercurial
# sudo apt-get install -y libncurses5-dev libgnome2-dev libgnomeui-dev \
#   libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev libx11-dev \
#   libxpm-dev libxt-dev
if [ $X ]; then
  sudo apt-get build-dep -y vim-gnome
else
  sudo apt-get build-dep -y vim-nox
fi

# Purge system Vim (unnecessary if install to /usr/local/)
# sudo apt-get remove vim-gnome vim-nox vim-runtime vim-tiny vim-common \
#   vim-gui-common --auto-remove

# Get the source code of Vim
vim_src='vim'
if [[ $(git config --get-regex remote.*url) == *vim/vim* ]]; then
  make distclean
  git reset --hard; git clean -dxfq
  git pull
else
  git clone --depth 1 git://github.com/vim/vim $vim_src
  cd $vim_src
fi

# Configure, compile and install Vim {{{1
pushd src

conf_cmd="./configure \
  --with-features=huge \
  --enable-pythoninterp=yes \
  --enable-python3interp=yes \
  --enable-rubyinterp=yes \
  --enable-luainterp=yes \
  --enable-multibyte \
  --disable-netbeans \
  --enable-fail-if-missing \
  --prefix=/usr/local \
  --with-compiledby=bohrshaw@gmail.com \
  --quiet"
  # --with-python-config-dir= \
  # --with-python3-config-dir= \
  # --enable-perlinterp \
  # --enable-cscope \
  # --with-global-runtime=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after \

if [ $X ]; then
  eval "$conf_cmd --enable-gui=gnome2"
else
  eval $conf_cmd
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
