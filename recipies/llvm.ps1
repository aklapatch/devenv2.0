# package details
$pkgname="llvm"

# required dependencies
$requires=@("7zip")

#https://www.7-zip.org/a/7z1806-x64.msi"https://julialang-s3.julialang.org/bin/winnt/x64/1.1/julia-1.1.0-win64.exe
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.exe"

function arrange($fname, $exdir) {

	# extract the files 
	7z x $fname -o"$exdir"| out-null
	
	Remove-Item "$exdir\Uninstall.exe"
	Remove-Item	"$exdir\`$PLUGINSDIR" -Recurse 
}

function getInfo() {
	# go to the download page and download the first file from top to bottom
	# that has a certain pattern
	# http://releases.llvm.org/7.0.1/LLVM-7.0.1-win64.exe
	$base_url="http://releases.llvm.org/download.html"
	
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
	$site=iwr "$base_url"
	$links=$site.links
	foreach ($link in $links) {
		if($link.href -Like "*LLVM*-win64.exe"){
			
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
	return  "http://releases.llvm.org/$url_extension"
}

function cleanUp($root_dir){

}