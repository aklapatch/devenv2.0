# package details
$pkgname="git"
$pkgver="2.20.1"

# packages that this one needs to install it
$requires=@("7zip")
#https://github.com/git-for-windows/git/releases/download/v2.20.1.windows.1/PortableGit-2.20.1-64-bit.7z.exe
$url="https://github.com/git-for-windows/git/releases/download/v$pkgver.windows.1/PortableGit-$pkgver-64-bit.7z.exe"
# name of the file once downloaded (it will be named that once the main script downloads it)
$fname="git$($pkgver).exe"

function arrange($fname, $exdir) {

	# we just need to move the files into the tmp dir
	7z x "$fname" -o"$exdir"
	echo "Please run the post-install.bat script in the installation directory."
}