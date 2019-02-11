# package details
$pkgname="gcc"
$pkgver="8.1.0"
$maver=""

# packages that this one needs to install it
$requires=@("7zip")
#https://cfhcable.dl.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z
$url="https://cfhcable.dl.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-$pkgver-release-posix-seh-rt_v6-rev0.7z"
# name of the file once downloaded (it will be named that once the main script downloads it)
$fname="gcc$($pkgver).7z"

function arrange($fname, $exdir) {

	# we just need to move the files into the tmp dir
	7z x "$fname" -o"$exdir"
}