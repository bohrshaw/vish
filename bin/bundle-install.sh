#!/usr/bin/env bash

# Extra works to installing bundles.

# Pre settings {{{1
# Set the bundle directory
pushd `dirname $0` > /dev/null
bundle_dir=`pwd -P`/../bundle
popd > /dev/null

# CD to the bundle directory
cd $bundle_dir

# Set the executable path
exe_path=~/local/bin
[ -d $exe_path ] || mkdir -p $exe_path

# YouCompleteMe {{{1
# Ensure you have Vim 7.3.584+ with python2 support
# Ensure required packages are installed
pkgs=(build-essential cmake python-dev)
for p in ${pkgs[@]}; do
  dpkg -s $p &> /dev/null || sudo apt-get install -y $p
done

# Start installation(for Linux)
pushd YouCompleteMe
# Compiling YCM without semantic support for C-family languages:
./install.sh
# Compiling YCM with semantic support for C-family languages:
# ./install.sh --clang-completer
popd

# Ag.vim {{{1
sudo apt-get install -y automake pkg-config libpcre3-dev zlib1g-dev liblzma-dev
pushd ~/local

git clone git://github.com/ggreer/the_silver_searcher.git ag
pushd  ag
./build.sh
chmod +x ag
mv ag $exe_path
popd

rm -rf ag

popd

# Gist-vim {{{1
sudo apt-get install -y curl

# Tarbar {{{1
sudo apt-get install -y exuberant-ctags

# Personal plug-in dependencies {{{1
# Markdown previewer {{{2
# Install multimarkdown from source.
pushd ~/local
git clone --depth 1 https://github.com/fletcher/MultiMarkdown-4.git multimarkdown

pushd multimarkdown
git submodule update --init
touch greg/greg.c # prevent an error which caused the build to fail
make
make test-all
chmod +x multimarkdown
mv multimarkdown $exe_path
popd

rm -rf multimarkdown

popd

# }}}1

# vim:tw=0 ts=2 sw=2 et fdm=marker:
