#!/usr/bin/env bash
# Link vimrc-esque files and install Vim plugins

pushd `dirname $0` > /dev/null
VISH=`pwd -P`
popd > /dev/null

# Smart and safe linking
slink () {
  # Return if the target doesn't exist or the same link already exists
  ( [[ ! -e $1 ]] || [[ $1 == `readlink $2` ]] ) && return
  mkdir -p ${2%/*} # ensure the link directory exists
  [[ -e $2 ]] && mv $2 $2.$(date +%F-%T) # backup
  ln -sfn $1 $2
}

# Link to $HOME/.vim, but avoid self-linking
[[ $VISH == $HOME'/.vim' ]] || slink $VISH $HOME/.vim

# Link vimrc files
for f in vimrc gvimrc vimperatorrc vimperator; do
  slink $VISH/$f $HOME/.$f
done
slink $VISH/vimrc $HOME/.nvimrc

$VISH/bin/vundle.rb

echo "Vim ready!"
