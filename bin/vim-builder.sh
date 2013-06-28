#!/usr/bin/env zsh

# This script compiles and installs vim under ubuntu. Reference links:
# https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source
# http://vim.wikia.com/wiki/Building_Vim
#
# Author: Bohr Shaw (mailto:pubohr@gmail.com)
# Copyright: Copyright (c) Bohr Shaw
# License: Distributes under the same terms as Ruby

# Ensure all the pre-required packages are installed {{{1
# Use `apt-get build-dep vim-gnome` to check what packages needed.
# Choose the essential.
pkgs=(libncurses5-dev libgnome2-dev libgnomeui-dev libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev python python-dev python3 python3-dev ruby-dev mercurial checkinstall)
for p in $pkgs; do
  dpkg -s $p > /dev/null 2>&1 || sudo apt-get install -y $p
done

# Purge system vim if installed {{{1
# Not necessary if you plan to install to /usr/local/.
# sudo apt-get remove vim-gnome vim-nox vim-runtime vim-tiny vim-common vim-gui-common --auto-remove

# Prepare the source of vim {{{1
src_dir='vim-src'

# Get the source
if [ -d $src_dir ]; then
  pushd $src_dir

  # Clean first
  make distclean

  # Update and clean the repository
  hg pull; hg update -C; hg purge --all

  popd
else
  hg clone https://code.google.com/p/vim/ $src_dir
fi

# Configure, compile and install vim {{{1
pushd $src_dir

./configure --enable-fail-if-missing \
            --prefix=/usr/local \
            --with-features=huge \
            --enable-gui=gnome2 \
            --enable-rubyinterp \
            --enable-pythoninterp=yes \
            --enable-python3interp=yes \
            --enable-multibyte \
            --enable-cscope \
            --disable-netbeans \
            --with-compiledby="Bohr Shaw(pubohr@gmail.com)" \
            --quiet # do not print 'checking...' messages
            # --with-python-config-dir= \
            # --with-python3-config-dir= \
            # --enable-perlinterp \
            # --with-global-runtime=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after \

make

# Install vim
# sudo make install
# Install vim prepackaged with a debian package format
sudo checkinstall

popd

# Set vim as your default editor with update-alternatives {{{1
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
sudo update-alternatives --set editor /usr/local/bin/vim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
sudo update-alternatives --set vi /usr/local/bin/vim

# }}}1

# vim:tw=0 ts=2 sw=2 et fdm=marker:
