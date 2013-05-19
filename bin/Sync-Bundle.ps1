param([switch]$update = $true, [switch]$clean = $false)

$vim_dir = ( Split-Path $script:MyInvocation.MyCommand.Path ) + '\..'
$bundle_dir = $vim_dir + '\vim\bundle'
$bundle_file = $vim_dir + '\vimrc.bundle'
pushd $bundle_dir

# Enable or clone bundles according to bundles specification.
function Enable-Bundle($bundles) {
    foreach ($bundle in $bundles) {
        $bundle_dir = $bundle.split('/')[-1]
        $bundle_url = 'git://github.com/' + $bundle + '.git'

        if (Test-Path $bundle_dir) {
            if ($update) {
                cd $bundle_dir; iex "git pull"; cd ..
            }
        }
        elseif (Test-Path "$bundle_dir~") {
            move-item "$bundle_dir~" $bundle_dir
        }
        else {
            iex "git clone $bundle_url"
        }
    }
}

# Disable bundles according to bundles specification.
function Disable-Bundle($bundles) {
    foreach ($dir in ls -exclude "*~") {
        foreach ($bundle in $bundles) {
            $bundle_dir = $bundle.split('/')[-1]
            if ($dir.name -eq $bundle_dir) {
                $dir_is_active = $true; break
            }
        }
        if (! $dir_is_active) {
            move-item $dir "$dir~"
        }
    }
}

# Clean disabled bundles
function Clean-Bundle {
    foreach ($dir in ls -filter "*~") {
        remove-item -recurse -force $dir
    }
}

$bundles = @()
foreach ($line in [System.IO.File]::ReadLines($bundle_file)) {
    if ($line -match '^" Bundle ''(.*\.*)''') {
        $bundles += $line.remove(0, 10).trimend("'")
    }
}

Enable-Bundle $bundles

Disable-Bundle $bundles

if($clean) { Clean-Bundle }

popd
