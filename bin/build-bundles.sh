#!/usr/bin/env bash

# Build native components of bundles

cd ~/.vim/bundle

pushd youcompleteme
pkgs="build-essential cmake python-dev"
for p in $pkgs; do
  dpkg -s "$p" &>/dev/null || sudo apt-get -y install "$p"
done
./install.sh --gocode-completer # --clang-completer
popd
