#!/bin/bash
# uncomment below to enable debug mode, or use 'bash -xv this_file.sh'
# set -xv 

# define variable
usage="Usage: $(basename $0) [-h] [-d directory] [-c repository] [-C] [-p] [-P]

Where:
    -h  show this help text
    -d  change target directory, default is '$HOME/.vim/bundle'
    -c  clone a repository, either specify the full URL
        or the short form like 'tpope/vim-pathogen'
    -C  clone all repositories specified in bundles.md
        abort if the destination directory already exists
    -p  pull repositories under the 'bundle' directory
    -P  pull repositories recursively under the 'bundle' directory
        max depth of directories is 3
    -s  in addition to cloning all bundles, also delete unused bundles
        as long as their directories not ended with '~'"

hflag=; dflag=; cflag=; Cflag=; pflag=; Pflag=; sflag=
while getopts "hd:c:CpPs" name; do
    case $name in
    h)    hflag=1;;
    d)    dflag=1
          dval="$OPTARG";;
    c)    cflag=1
          cval="$OPTARG";;
    C)    Cflag=1;;
    p)    pflag=1;;
    P)    Pflag=1;;
    s)    sflag=1;;
    ?)    printf "Usage: %s: [-h] [-c args] [-C] [-p] [-P] -- clone or pull git repositories.\n" $0
          exit 2;;
    esac
done

if [ ! -z "$hflag" ] || [ $# -eq 0 ]; then
  echo "$usage" >&2
fi

if [ ! -z "$dflag" ]; then
  BUNDLE_DIR="$dval"
else
  [ ! -d $HOME/.vim/bundle ] && mkdir "$HOME/.vim/bundle"
  BUNDLE_DIR="$HOME/.vim/bundle"
fi
BUNDLE_FILE="$HOME/vimise/vimrc.bundle"

cd $BUNDLE_DIR

if [ ! -z "$cflag" ]; then
  cd $BUNDLE_DIR
  if [[ $cval == git* ]] || [[ $cval == http* ]] || [[ $cval == ssh* ]]; then
    tmp=${cval##*\/}; dest=${tmp%%.git}
    git clone $cval $dest
  else
    git clone "git://github.com/${cval}.git"
  fi
fi

function clone_all_bundles(){
  echo "Cloning bundles..."
  # Get the URL list of bundles, the format '\'' match a '
  url_list="$(grep '^" Bundle ' $BUNDLE_FILE \
    | sed 's_" Bundle '\''\(.*\)'\''_git://github.com/\1.git_')"
  cd $BUNDLE_DIR
  let count=0
  for url in $url_list; do
    tmp=${url##*\/}; dest=${tmp%%.git}
    if [ ! -d $dest ]; then
      echo "Cloning into $dest..."
      git clone $url
      let count+=1
    fi
  done
  echo "Cloning $count bundles finished."
}

if [ ! -z "$Cflag" ]; then
  clone_all_bundles
fi

if [ ! -z "$pflag" ]; then
  echo "Pull bundles..."
  # Update all git repositories under current directory,
  # excluding directories end with '~'
  let count=0
  for d in $(ls -d *[^~]); do
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $d"
    (cd $d; git pull)
    let count+=1
  done
  echo "Pull $count bundles finished."
fi

if [ ! -z "$Pflag" ]; then
  echo  "Pull bundles recursively..."
  # Update all git repositories under current directory recursively(maxdepth is 3),
  # excluding directories end with '~'
  let count=0
  for d in $( find . -maxdepth 3 -path '*~' -prune -o -type d -name .git -print ); do
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${d%/.git}"
    (cd ${d%/.git}; git pull)
    let count+=1
  done
  echo  "Pull $count bundles recursively finished."
fi

if [ ! -z "$sflag" ]; then
  echo "Syncing bundles(directories)..."
  bundle_list="$(grep '^" Bundle ' $BUNDLE_FILE | sed "s/.*\/\(.*\)'/\1/")"
  clone_all_bundles
  dir_list="$(ls -d *[^~])"
  # for every directory in dir_list and not in bundle_list, delete it.
  for i in $dir_list; do
    match=0
    for j in $bundle_list; do
      [[ "$i" == "$j" ]] && match=1 && break
    done
    [[ "$match" != 1 ]] && rm -rf $i
  done
  echo "Syncing bundles(directories) finished."
fi

shift $(($OPTIND - 1))
