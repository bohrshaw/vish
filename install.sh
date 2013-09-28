#!/usr/bin/env bash
# Install the "VIMISE" distribution.

pushd `dirname $0` > /dev/null
VIM_DIR=`pwd -P`
popd > /dev/null

echo "Start installation ..."

echo "Back up and link files ..."
today=`date +%Y%m%d`
backup () {
  # Backup only non symbol link files.
  if [ -e $1 ] && [ ! -L $1 ]; then
    mv $1 $1.$today
    echo "$1 has been renamed to $1.$today."
  fi
}

# Check whether the repository path is already ~/.vim
if [[ $VIM_DIR != $HOME'/.vim' ]]; then
  backup $HOME'/.vim'
  ln -sfn $VIM_DIR $HOME/.vim
fi

for f in vimrc gvimrc vimrc.light; do
  backup $HOME/.$f
  ln -sf $VIM_DIR/$f $HOME/.$f
done

echo "Clone bundles ..."
$VIM_DIR/bin/bundle.rb

echo "Generate help tags ..."
vim -Nesu ~/.vim/vimrc.bundle --noplugin +BundleDocs +qa

echo "Installation done."
