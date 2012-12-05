#! /bin/bash
# install vimise vim distribution
# vimise with vimperator

# link the repository to $HOME, so you can put this repository anywhere
if [ ! -d $HOME/vimise ]; then
    ln -sfn $PWD $HOME
fi

vimise_path="$HOME/vimise"

echo "linking files..."
ln -sfn $vimise_path/vim $HOME/.vim
ln -sf $vimise_path/vimrc $HOME/.vimrc
ln -sf $vimise_path/gvimrc $HOME/.gvimrc

ln -sfn $vimise_path/vimperator $HOME/.vimperator
ln -sf $vimise_path/vimperatorrc $HOME/.vimperatorrc

# echo "create extra directories..."

echo "install vundle..."
if [ ! -d $vimise_path/vim/bundle ]; then
    mkdir -p $vimise_path/vim/bundle
fi

if [ ! -e $vimise_path/vim/bundle/vundle ]; then
    git clone http://github.com/gmarik/vundle.git $vimise_path/vim/bundle/vundle
fi

echo "install bundles using vundle..."
vim -u $vimise_path/bootstrap_vundle.vim +BundleInstall +qa
