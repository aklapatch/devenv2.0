
# add these to the path
$root="$PSScriptRoot\root"
$bin="$root\bin"

# add here
echo "adding $root;$bin to the PATH"
$env:Path +=";$root;$bin"

cmd /k