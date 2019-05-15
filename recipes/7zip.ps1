# package details
$pkgname="7zip"

# required dependencies
$requires=@()


#https://www.7-zip.org/a/7z1806-x64.msi"
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.msi"


function arrange($fname, $exdir) {

	msiexec.exe /a "$($fname)" /qb TARGETDIR="$exdir"  | out-null
	
	move "$exdir\Files\7-zip\*" "$exdir\bin"
	Remove-Item -Path "$exdir\$download_name" -Force
	Remove-Item "$exdir\Files\" -Force -Recurse
}

# this function returns an array of tuples with the first entry being the file
# in the extracted dir, and the second one being the path for the link that 
# should be made for that first entry
# relative paths should be used for this
# the $ExDir arg is going to be set to the root of the extraction directory
function getLinks() {
	$Dir = "Files\7-zip\" # the inner directory for 7-zip

	return @([Tuple]::Create("$Dir\7z.exe","bin\7z.exe")
				[Tuple]::Create("$Dir\7zFM.exe","bin\7zFM.exe") 
				[Tuple]::Create("$Dir\7zG.exe","bin\7zG.exe")  )
}

function getInfo() {
	# go to the download page and download the first file from top to bottom
	# that has the pattern '7z*-x64.msi'
	
	$base_url="https://www.7-zip.org/"
	
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