#!/usr/bin/env bash
# Install the "Vish" distribution.

pushd `dirname $0` > /dev/null
VIM_DIR=`pwd -P`
popd > /dev/null

today=`date +%Y%m%d`
backup () {
  # Backup only non symbol link files.
  if [ -e $1 ] && [ ! -L $1 ]; then
    mv $1 $1.$today
    echo "$1 has been renamed to $1.$today."
  fi
}

echo "Start installation ..."
echo "Back up and link files ..."

# Link this repository if its path isn't ~/.vim
if [[ $VIM_DIR != $HOME'/.vim' ]]; then
  backup $HOME'/.vim'
  ln -sfn $VIM_DIR $HOME/.vim
fi

# Link vimrc files
for f in vimrc gvimrc; do
  backup $HOME/.$f
done
ln -sf $VIM_DIR/vimrc.heavy $HOME/.vimrc
ln -sf $VIM_DIR/vimrc.light $HOME/.vimrc.light

echo "Clone bundles ..."
$VIM_DIR/bin/bundle.rb

echo "Installation done."
