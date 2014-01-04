# A Vim version updated and optional features included
$URL = 'http://tuxproject.de/projects/vim/complete.7z'

# Downloading
aria2c -x8 $URL

# Extracting
& 7z x -yoD:\Programs\Vim\vim74 complete.7z

# Remove the archive
rm complete.7z
