# package details
$pkgname="zig"

# required dependencies
$requires=@("7zip")

# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.zip"

function arrange($fname, $exdir) {

	7z x "$($fname)" -o"$exdir"  | out-null

	Get-ChildItem -Path "$exdir\zig-windows*\*" -Force | Move-Item -Destination "$exdir"

	# remove directory
	Remove-Item "$exdir\zig-windows-*" -Force
}

function getInfo() {
	# go to the download page and download the first file from top to bottom
	# that has the right pattern
	
	$base_url="https://ziglang.org/download/"

	$site=iwr -uri "$base_url"
	$Lnum = 0
	$links=$site.parsedhtml.getelementsbytagname("a")
	foreach ($link in $links) {
		if($link.tagName -eq "A") {
			if($link.href -Like "*zig-windows-x86_64-*.zip"){
				
				$download_url=$link.href.Trim()
				
				# only get the second link
				if ($Lnum -gt 0){
					break
				}
				$Lnum += 1
			}
		}
	}
	
	# get the version (get text in between 64- and the .zip
	$dex1=$download_url.indexof('4-')
	$dex2=$download_url.indexof('.zip')
	
	$len=$dex2-$dex1
	
	$version=$download_url.substring($dex1+2,$len-2)
	
	return @($version,$download_url)
}

function cleanUp($root_dir){
	
}