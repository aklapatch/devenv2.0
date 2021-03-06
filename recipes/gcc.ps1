# package details
$pkgname="gcc"

# required dependencies
$requires=@("7zip")


# https://newcontinuum.dl.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.7z"

# Files to link as a executables (get linked over as .bat files)
$PackageExecFiles =  makeTransferList "bin" "bin" "exe" @("addr2line","ar","as",
  "dlltool", "dllwrap", "dwp", "elfedit", "g++", "gcc", "gcc-ar","gcc-nm",    
  "gcc-ranlib","gdb","gdbserver","gendef","mingw32-make","objcopy","objdump",
  "ranlib","readelf","size","strings","strip","windres")

function arrange($fname, $exdir) {
  7z x "$($fname)" -o"$exdir" | Out-Null
}

function getInfo() {
  
  $base_url="https://newcontinuum.dl.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds"

  $version="8.1.0"

  return @($version,"$base_url/$version/threads-posix/seh/x86_64-$version-release-posix-seh-rt_v6-rev0.7z")
}

function cleanUp($root_dir){
  
}