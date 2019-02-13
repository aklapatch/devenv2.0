# package details
$pkgname="7zip"

# required dependencies
$requires=@()


#https://www.7-zip.org/a/7z1806-x64.msi"
$base_url="https://www.7-zip.org/"
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="7z.msi"

function arrange($fname, $exdir) {

	msiexec.exe /a "$($fname)" /qb TARGETDIR="$exdir" | Wait-Process
	
	move "$exdir\Files\7-zip\*" "$exdir\bin"
	Remove-Item -Path "$exdir\7z$($pkgver).msi" -Force
	Remove-Item "$exdir\Files\" -Force -Recurse
}

function getFile($base_url,$download_name) {
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
	Write-Output $url_extension
	
	# download the file
	iwr "$base_url\$url_extension" -OutFile $download_name
}

function cleanUp($root_dir){


}