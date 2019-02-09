# package details
$pkgname="7zip"
$pkgver="1806"

# required dependencies
$requires=@()

#https://www.7-zip.org/a/7z1806-x64.msi"
$url="https://www.7-zip.org/a/7z$($pkgver)-x64.msi"
# name of the file once downloaded (it will be named that once the main script downloads it)
$fname="7z$($pkgver).msi"

function arrange($fname, $exdir) {

	msiexec.exe /a "$($fname)" /qb TARGETDIR="$exdir" | Wait-Process
	
	move "$exdir\Files\7-zip\*" "$exdir\bin"
	Remove-Item -Path "$exdir\7z$($pkgver).msi" -Force
	Remove-Item "$exdir\Files\" -Force -Recurse
}