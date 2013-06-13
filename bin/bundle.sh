#!/usr/bin/env bash

# Uncomment below to enable debug mode, or use 'bash -xv this_file.sh'
# Set -xv 

# Usage documentation
usage="Usage: $(basename $0) [-c] [-p] [-C]\n
\n
Where:\n
-c  clone all bundles(default)\n
-p  pull all bundles\n
-C  clean inactive bundles\n"

# Parse command line options
cflag=; pflag=; Cflag=
while getopts "cpC" name; do
    case $name in
    c)    cflag=1;;
    p)    pflag=1;;
    C)    Cflag=1;;
    ?)    echo -e $usage; exit;;
    esac
done

# Print the usage if illegal options are passed
[[ $# -gt 0 ]] && [[ ${1:0:1} != '-' ]] && echo -e $usage && exit

# Get the full path of the current script
pushd `dirname $0` > /dev/null
SCRIPT_DIR=`pwd -P`
popd > /dev/null

# Get the path to repository root
VIM_DIR=${SCRIPT_DIR%/*}

# Get the path to bundles
[ ! -d $VIM_DIR/bundle ] && mkdir "$VIM_DIR/bundle"
BUNDLE_DIR="$VIM_DIR/bundle"

# Get the path to the bundle specification file
BUNDLE_FILE="$VIM_DIR/vimrc.bundle"

# Change the working directory to the bundle's path
cd $BUNDLE_DIR

# Get the URL list of bundles
url_list="$(grep '^\s*Bundle ' $BUNDLE_FILE \
  | sed 's_\s*Bundle '\''\(.*\)'\''_git://github.com/\1.git_')"

# Clone or pull all bundles
for url in $url_list; do
  # Get the destination to clone to
  tmp=${url##*\/}; dest=${tmp%%.git}

  # A command to init and update git submodule
  gsm="git submodule update --init"

  # Clone
  if [[ $# -eq 0 ]] || [[ -n "$cflag" ]]; then
    if [ ! -d $dest ]; then
      echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $dest"
      git clone $url
      ( cd $dest; $gsm )
    fi
  fi

  # Pull
  if [ -n "$pflag" ]; then
      echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $dest"
      ( cd $dest; git pull; $gsm )
  fi
done

# Clean inactive bundles
if [[ -n $Cflag ]]; then
  # Get the bundle directory list
  bundle_dir_list="$(grep '^\s*Bundle ' $BUNDLE_FILE | sed "s/.*\/\(.*\)'/\1/")"

  for i in *; do
    match=false
    for j in $bundle_dir_list; do
      [[ "$i" == "$j" ]] && match=true && break
    done
    ! $match && rm -rf $i
  done
fi

# shift $(($OPTIND - 1))
