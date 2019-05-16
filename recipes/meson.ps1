# package details
$pkgname="meson"

# required dependencies
$requires=@("7zip")


#https://github.com/ninja-build/ninja/releases
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.msi"

# Files to link as a executables (get linked over as .bat files)
$PackageExecFiles =@([Tuple]::Create("Meson\meson.exe","bin\meson.exe"))

function arrange($fname, $exdir) {
	msiexec.exe /a "$($fname)" /qb TARGETDIR="$exdir" | Out-Null
}

function getInfo() {
	# go to the download page and download the first file from top to bottom
	# that has the right pattern
	
	$base_url="https://github.com/mesonbuild/meson/releases"

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
	$page=(New-Object System.Net.WebClient).DownloadString("$base_url")
	#https://github.com/mesonbuild/meson/releases/download/0.50.1/meson-0.50.1-64.msi
	$searchStr = '/meson-.*-64.msi' # search with .* wildcard
	$dex= ($page | Select-String $searchStr ).Matches.Index # get the first match

	return @($version,"$base_url/download/$version/meson-$version-64.msi")
}

function cleanUp($root_dir){
	
}