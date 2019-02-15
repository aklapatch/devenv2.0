# package details
$pkgname="7zip"

# required dependencies
$requires=@()


#https://www.7-zip.org/a/7z1806-x64.msi"
$base_url="https://www.7-zip.org/"
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.msi"

function arrange($fname, $exdir) {

	msiexec.exe /a "$($fname)" /qb TARGETDIR="$exdir"  | out-null
	
	move "$exdir\Files\7-zip\*" "$exdir\bin"
	Remove-Item -Path "$exdir\$download_name" -Force
	Remove-Item "$exdir\Files\" -Force -Recurse
}

function getInfo($base_url) {
	# go to the download page and download the first file from top to bottom
	# that has the pattern '7z*-x64.msi'
	
	$site=iwr -uri "$base_url/download.html"
	$links=$site.parsedhtml.getelementsbytagname("a")
	foreach ($link in $links) {
		if($link.tagName -eq "A") {
			if($link.href -Like "*7z*-x64.msi"){
			
				$url_extension=$link.href
				break
			}
		}
	}
	# pull out about: text
	$url_extension=$url_extension.substring($url_extension.indexOf(":")+1)
	
	$version=$url_extension.substring(4,4)
	
	# download the file
	#iwr "$base_url\$url_extension" -OutFile $download_name
	
	return @($version,"$base_url$url_extension")
}

function cleanUp($root_dir){

}