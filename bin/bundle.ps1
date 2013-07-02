param([switch]$pull = $false, [switch]$clean = $false)

$vim_dir = ( Split-Path $script:MyInvocation.MyCommand.Path ) + '\..'
$bundle_root = $vim_dir + '\bundle'
$bundle_file = $vim_dir + '\vimrc.bundle'

# Ensure the 'bundle' root directory exists
if (! (Test-Path $bundle_root)) {
    mkdir $bundle_root
}
pushd $bundle_root

# Clone or pull bundles according to bundles specification.
function Bundle-Bundle($bundles) {
    foreach ($bundle in $bundles) {
        $bundle_dir = $bundle.split('/')[-1]
        $bundle_url = 'git://github.com/' + $bundle + '.git'

        # A command to init and update git submodules
        $gsm="git submodule update --init"

        if (Test-Path $bundle_dir) {
            if ($pull) {
                echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $bundle_dir"
                pushd $bundle_dir; iex "git pull; $gsm"; popd
            }
        }
        else {
            if (Test-Path "$bundle_dir~") {
                move-item "$bundle_dir~" $bundle_dir
            }
            else {
                echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $bundle_dir"
                iex "git clone --depth 1 $bundle_url"
                pushd $bundle_dir; iex $gsm; popd
            }
        }
    }
}

# Clean bundles according to bundles specification.
function Clean-Bundle($bundles) {
    foreach ($dir in ls) {
        $dir_is_active = $false

        foreach ($bundle in $bundles) {
            $bundle_dir = $bundle.split('/')[-1]
            if ($dir.name -eq $bundle_dir) {
                $dir_is_active = $true; break
            }
        }

        if (! $dir_is_active) {
            remove-item -recurse -force $dir
        }
    }
}

$bundles = @()
foreach ($line in [System.IO.File]::ReadLines($bundle_file)) {
    if ($line -match '^\s*Bundle ''(.*\.*)''') {
        $line = $line -replace "^\s*Bundle\s+'(.*)'", '$1'
        $bundles += $line
    }
}

Bundle-Bundle $bundles

if($clean) { Clean-Bundle $bundles }

popd
