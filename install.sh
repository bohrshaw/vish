#!/usr/bin/env bash
# Link vimrc files and install Vim plugins

# Get the directory path of this file
VISH="$(cd "$(dirname "$0")" && pwd -P)"
VIM="$HOME/.vim"
NVIM="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

# Smart and safe linking
slink () {
  [[ ! -e $1 || $1 == $(readlink "$2") || $1 == "$2" ]] &&
    return
  mkdir -p "${2%/*}"
  # Make a backup only if not a link
  [[ -e $2 && ! -L $2 ]] && mv "$2" "$2.$(date +%F-%T)"
  ln -sfn "$1" "$2"
}

# Link the repository root
slink "$VISH" "$VIM"
slink "$VISH" "$NVIM"

# Link vimrc files
for f in vimrc gvimrc; do
  slink "$VISH/$f" "$HOME/.$f"
done
slink "$VISH/vimrc" "$NVIM/init.vim"
slink "$VISH/external/vimfx" "$HOME/.config/vimfx"

clone() {
  if [ -e ~/.ssh/id_rsa ]; then
    git clone git@git.coding.net:bohrshaw/$1 $2
  else
    git clone https://git.coding.net/bohrshaw/$1 $2
    git -C $2 remote set-url origin git@${1/\//:}
  fi
}

# Include spell related files(mostly static and large)
if vspell=$VISH/spell && [[ ! -e $vspell/.git ]]; then
  [[ -d $vspell ]] && mv "$vspell" "${vspell}.bak"
  clone vish-spell "$vspell"
  for f in spl sug; do
    curl -o "$vspell/en.utf-8.$f" \
      http://ftp.vim.org/pub/vim/runtime/spell/en.utf-8.$f &>/dev/null &
  done
fi

# Sync bundles
if hash vundle &>/dev/null; then
  vundle
elif hash go &>/dev/null; then
  go get -u github.com/bohrshaw/vundle
  vundle
else
  echo "Fatal: Vish depends on Golang to install bundles!"
fi

wait
echo "Vim ready!"
