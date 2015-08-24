#!/usr/bin/env bash
# Link vimrc-esque files and install Vim plugins

# Get the directory path of this file
VISH="$( cd `dirname $0` && pwd -P )"

# Smart and safe linking
slink () {
  # Return if the target doesn't exist or the same link already exists
  ( [[ ! -e $1 ]] || [[ $1 == `readlink $2` ]] ) && return
  mkdir -p ${2%/*} # ensure the link directory exists
  # Backup only if not a link
  [[ -e $2 ]] && [[ ! -L $2 ]] && mv $2 $2.$(date +%F-%T)
  ln -sfn $1 $2
}

# Link to $HOME/.vim, but avoid self-linking
[[ $VISH == $HOME'/.vim' ]] || slink $VISH $HOME/.vim

# Link vimrc files
for f in vimrc gvimrc vimperatorrc vimperator; do
  slink $VISH/$f $HOME/.$f
done
slink $VISH/vimrc $HOME/.nvimrc

# Include spell related files(mostly static and large)
if [[ ! -d $VISH/spell/.git ]]; then
  [[ -d $VISH/spell ]] && mv $VISH/spell $VISH/spell.bak
  git clone git@git.coding.net:bohrshaw/vish-spell.git $VISH/spell &
fi

# Sync bundles
if hash go &>/dev/null; then
  go run $VISH/bin/src/vundle/vundle.go
else
  $VISH/bin/vundle.rb
fi

wait

echo "Vim ready!"
