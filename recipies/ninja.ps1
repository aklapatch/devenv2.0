# package details
$pkgname="ninja"

# required dependencies
$requires=@("7zip")


#https://github.com/ninja-build/ninja/releases
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.zip"

function arrange($fname, $exdir) {

	7z x "$($fname)" -o"$exdir\bin"  | out-null
	
}

function getInfo() {
	# go to the download page and download the first file from top to bottom
	# that has the right pattern
	
	$base_url="https://github.com/ninja-build/ninja/releases"

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
	$page=(New-Object System.Net.WebClient).DownloadString("$base_url")
	
	$searchStr = '/ninja-build/ninja/releases/tag/v'
	$dex=$page.IndexOf($searchStr) + $searchStr.length
	$endDex = $page.IndexOf('>',$dex) - 1;
	# pull out version
	
	$version=$page.Substring($dex,$endDex - $dex)

	return @($version,"$base_url/download/v$version/ninja-win.zip")
}

function cleanUp($root_dir){
	
}