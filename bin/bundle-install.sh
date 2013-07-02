#!/usr/bin/env bash

# Extra works to installing bundles.

# Pre settings {{{1
# Get the script path
pushd `dirname $0` > /dev/null
script_path=`pwd -P`
popd > /dev/null

# CD to the bundle directory
cd $script_path/../bundle

# YouCompleteMe {{{1
# Ensure you have Vim 7.3.584+ with python2 support
# Ensure required packages are installed
pkgs=(build-essential cmake python-dev)
for p in ${pkgs[@]}; do
  dpkg -s $p > /dev/null 2>&1 || sudo apt-get install -y $p
done

# Start installation(for Linux)
pushd YouCompleteMe
# Compiling YCM without semantic support for C-family languages:
./install.sh
# Compiling YCM with semantic support for C-family languages:
# ./install.sh --clang-completer
popd

# Markdown previewer {{{1
# Install multimarkdown from source.
[ -d ~/local/bin ] || mkdir -p ~/local/bin
pushd ~/local
git clone --depth 1 https://github.com/fletcher/MultiMarkdown-4.git multimarkdown

pushd multimarkdown
git submodule update --init
touch greg/greg.c # prevent an error which caused the build to fail
make
make test-all
chmod +x multimarkdown
ln -sf ~/local/multimarkdown/multimarkdown ~/local/bin
popd

popd

# }}}1

# vim:tw=0 ts=2 sw=2 et fdm=marker:
