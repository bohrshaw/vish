#!/bin/bash

BUNDLE_DIR="$HOME/vimise/vim/bundle"
cd $BUNDLE_DIR

echo "updating bundles..."

# Pull directories not ended with '~' in current path
for d in $(ls -d *[^~])
do
    echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ $d @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
    (cd $d; git pull)
done

# Update all git repositories under current directory recursively
#find . -type d -name .git | while read f
#do
#echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ${f%/.git} @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
    #(cd ${f%/.git}; git pull)
#done

echo "updating bundles finished."
