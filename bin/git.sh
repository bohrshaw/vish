#!/bin/bash
# Uncomment below to enable debug mode, or use 'bash -xv this_file.sh'
# Set -xv 

# Define variable
usage="Usage: $(basename $0) [-h] [-d directory] [-c repository] [-C] [-p] [-P] [-s]

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
    ?)    printf "Usage: $(basename $0) [-h] [-d directory] [-c repository] [-C] [-p] [-P] [-s]\n" $0
          exit 2;;
    esac
done

# Display help.
if [ -n "$hflag" ] || [ $# -eq 0 ]; then
  echo "$usage" >&2
fi

# Set up the working directory.
if [ -n "$dflag" ]; then
  BUNDLE_DIR="$dval"
else
  [ ! -d $HOME/.vim/bundle ] && mkdir "$HOME/.vim/bundle"
  BUNDLE_DIR="$HOME/.vim/bundle"
fi
cd $BUNDLE_DIR
BUNDLE_FILE="$HOME/vimise/vimrc.bundle"

# Clone a single repository.
if [ -n "$cflag" ]; then
  if [[ $cval == git* ]] || [[ $cval == http* ]] || [[ $cval == ssh* ]]; then
    tmp=${cval##*\/}; dest=${tmp%%.git}
    git clone $cval $dest
  else
    git clone "http://github.com/${cval}.git"
  fi
fi

# Clone all the repositories specified in the BUNDLE_FILE
function clone_all_bundles(){
  echo "Cloning bundles ..."
  # Get the URL list of bundles, the format '\'' match a '
  url_list="$(grep '^" Bundle ' $BUNDLE_FILE \
    | sed 's_" Bundle '\''\(.*\)'\''_http://github.com/\1.git_')"
  let count=0
  for url in $url_list; do
    tmp=${url##*\/}; dest=${tmp%%.git}
    if [ ! -d $dest ]; then
      echo "Cloning into $dest ..."
      git clone $url
      let count+=1
    fi
  done
  echo "Cloning $count bundles finished."
}
if [ -n "$Cflag" ]; then clone_all_bundles; fi

# Update all the bundles under the current working path.
if [ -n "$pflag" ]; then
  echo "Pull bundles ..."
  let count=0
  # Excluding directories end with '~'
  for d in $(ls -d *[^~]); do
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $d"
    (cd $d; git pull)
    let count+=1
  done
  echo "Pull $count bundles finished."
fi

# Update all the bundles RECURSIVELY under the current working path.
if [ -n "$Pflag" ]; then
  echo  "Pull bundles recursively ..."
  let count=0
  # Don't descent into a directory which is a git repository
  # and exclude directories end with '~'
  #for d in $( find . -exec test -d '{}'/.git \; ! -path '*~' -print -prune ); do
  # As the above don't work in msysgit bash, here comes a solution of compromise.
  for d in $( find . -maxdepth 3 -path "*~" -prune -o \
                     -type d -name ".git" -print -prune ); do
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${d%/.git}"
    (cd ${d%/.git}; git pull)
    let count+=1
  done
  echo  "Pull $count bundles recursively finished."
fi

# Auto clone and delete directories according bundles specified within the BUNDLE_FILE.
if [ -n "$sflag" ]; then
  echo "Syncing bundles(directories) ..."
  bundle_list="$(grep '^" Bundle ' $BUNDLE_FILE | sed "s/.*\/\(.*\)'/\1/")"
  clone_all_bundles
  dir_list="$(ls -d *[^~])" # Don't delete directories ended with "~".
  # For every directory in dir_list and not in bundle_list, delete it.
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
