# package details
$pkgname="conemu"
$pkgver="190108"
$maver=""

# packages that this one needs to install it
$requires=@("7zip")
#https://cfhcable.dl.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z
$url="https://github.com/Maximus5/ConEmu/releases/download/v19.01.08/ConEmuPack.190108.7z"
# name of the file once downloaded (it will be named that once the main script downloads it)
$fname="$($pkgname)$($pkgver).7z"

function arrange($fname, $exdir) {

	# we just need to move the files into the tmp dir
	7z x "$fname" -o"$exdir"
}
