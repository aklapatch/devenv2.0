# package details
$pkgname="julia"

# required dependencies
$requires=@("7zip")

#https://www.7-zip.org/a/7z1806-x64.msi"https://julialang-s3.julialang.org/bin/winnt/x64/1.1/julia-1.1.0-win64.exe
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.exe"

function arrange($fname, $exdir) {

	# there is a file called 'julia-installer.exe' that needs to be extracted
	7z x $fname -o"$exdir" | out-null
	
	# extract the julia installer
	7z x "$exdir\$pkgname-installer.exe" -o"$exdir\" | out-null
	
	Remove-Item "$exdir\Uninstall.exe"
	Remove-Item "$exdir\$pkgname-installer.exe"
	Remove-Item	"$exdir\`$PLUGINSDIR" -Recurse 
}

function getInfo() {
	# go to the download page and download the first file from top to bottom
	# that has a certain pattern
	
	$base_url="https://julialang.org/downloads/"
	
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
	$site=iwr "$base_url"
	$links=$site.links
	foreach ($link in $links) {
		if($link.href -Like "*julia*-win64.exe"){
			
			$url_extension=$link.href
			break
		}
	}
	# pull out version
	$startDex=$url_extension.indexOf("-win64.exe") - 5
	$version=$url_extension.substring($startDex, 5)
	
	# download the file
	#iwr "$base_url\$url_extension" -OutFile $download_name
	
	# returns both values
	$version
	$url_extension
}

function cleanUp($root_dir){

}