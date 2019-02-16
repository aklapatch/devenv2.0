# package details
$pkgname="conemu"

# required dependencies
$requires=@("7zip")


#https://github.com/Maximus5/ConEmu/releases/download/v19.01.08/ConEmuPack.190108.7z
$base_url="https://github.com/Maximus5/ConEmu/releases"
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.7z"

function arrange($fname, $exdir) {

	7z x "$($fname)" -o"$exdir"  | out-null
	
}

function getInfo($base_url) {
	# go to the download page and download the first file from top to bottom
	# that has the right pattern

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
	$page=(New-Object System.Net.WebClient).DownloadString("$base_url")
	
	$dex=$page.IndexOf("ConEmuPack")
	# pull out version
	$version=$page.Substring($dex+11,6)

	$year=$version.Substring(0,2)
	$month=$version.Substring(2,2)
	$day=$version.Substring(4,2)
	
	Write-Output "$base_url/download/v$year.$month.$day/ConEmuPack.$version.7z"

	return @($version,"$base_url/download/v$year.$month.$day/ConEmuPack.$version.7z")
}

function cleanUp($root_dir){
	Remove-Item "$root_dir\ConEmu" -Force -Recurs
}