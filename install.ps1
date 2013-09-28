Param ( [Switch] $override=$false )

# Supporting functions {{{
function New-Link {
    param([String]$target, [String]$link)

    # Generate the line path ifomitted.
    if(! $link) {
        $link = "$HOME\." + $target.split('\')[-1]
    }

    # What to do ifthe link existed.
    if(Test-Path $link) {
        if($script:override) {
            if(Test-Path -type container $link) {
                [System.IO.Directory]::Delete($link)
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
$vim_dir = Split-Path $script:MyInvocation.MyCommand.Path

# Link this repository to ~/.vim
New-Link $vim_dir $HOME\.vim

# Link vimrc files
$targets = @("vimrc", "vimrc.light", "vsvimrc")
foreach( $target in $targets ) { New-Link "$vim_dir\$target" }

# Sync bundles
Invoke-Expression "ruby $vim_dir\bin\bundle.rb"

# Generate help tags
Invoke-Expression "vim -Nesu ~/.vim/vimrc.bundle --noplugin +BundleDocs +qa"

# vim:tw=80 ts=4 sw=4 et fdm=marker:
