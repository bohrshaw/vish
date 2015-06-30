Param ( [Switch] $Force=$false )

# Supporting functions {{{
function New-Link {
    param([String]$target, [String]$link)

    # Generate the line path ifomitted.
    if(! $link) {
        $link = "$HOME\." + $target.split('\')[-1]
    }

    # What to do if the link is existed.
    if(Test-Path $link) {
        if($script:Force) {
            if(Test-Path -type container $link) {
                [System.IO.Directory]::Delete($link, 1)
            }
            else { remove-item $link }
        }
        else { write "$link already existed."; return }
    }

    # Create the link.
    if(Test-Path -type container $target) {
        Invoke-MKLink "/J" $link $target
    }
    else { Invoke-MKLink $link $target }
}

function Invoke-MKLink { cmd /c mklink $args }
# }}}

# Environment variables
$VIM_DIR = Split-Path $script:MyInvocation.MyCommand.Path

# Link this repository if its path isn't ~/.vim
if($VIM_DIR -ne (Convert-Path '~\.vim')) {
    New-Link $VIM_DIR $HOME\.vim
}

# Link vimrc files
New-Link "$VIM_DIR\vimrc" "$HOME\.vimrc"
New-Link "$VIM_DIR\gvimrc" "$HOME\.gvimrc"
New-Link "$VIM_DIR\vimperatorrc" "$HOME\.vimperatorrc"
New-Link "$VIM_DIR\vimperator" "$HOME\vimperator"
New-Link "$VIM_DIR\vsvimrc"

# Sync bundles
if (Get-Command "go.exe" -ErrorAction SilentlyContinue) {
    Invoke-Expression "go run $VIM_DIR\bin\bundle.go"
} else {
    Invoke-Expression "ruby $VIM_DIR\bin\bundle.rb"
}

# vim:tw=80 ts=4 sw=4 et fdm=marker:
