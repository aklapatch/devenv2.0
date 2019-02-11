# package details
$pkgname="python"
$pkgver="3.7.2"
$maver="37"

# packages that this one needs to install it
$requires=@("7zip")
#https://www.python.org/ftp/python/3.7.2/python-3.7.2.post1-embed-amd64.zip
$url="https://www.python.org/ftp/python/$pkgver/python-$pkgver.post1-embed-amd64.zip"
# name of the file once downloaded (it will be named that once the main script downloads it)
$fname="python$($pkgver).exe"

function arrange($fname, $exdir) {

	# we just need to move the files into the tmp dir
	7z x "$fname" -o"$exdir"
	
	# revise the python37._pth file to ensure normal python behavior
	$out="lib/site-packages `n python36.zip `n.`n# Uncomment to run site.main() automatically`n import site`n"
	echo "$out" > "$exdir\python$($maver)._pth"
}