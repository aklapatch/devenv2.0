# package details
$pkgname="nodejs"

# required dependencies
$requires=@()

# this is the lts version
#https://nodejs.org/en/download/
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.msi"

function arrange($fname, $exdir) {

	msiexec.exe /a "$($fname)" /qb TARGETDIR="$exdir"  | out-null
	
	move "$exdir\nodejs\*" "$exdir\"
	Remove-Item -Path "$exdir\$download_name" -Force
	Remove-Item "$exdir\nodejs\" -Force -Recurse
}

function getInfo() {
	# go to the download page and download the first file from top to bottom
	# that has the pattern '7z*-x64.msi'
	$base_url="https://nodejs.org/en/download/"
	
	$site=iwr -uri "$base_url"
	$links=$site.parsedhtml.getelementsbytagname("a")
	foreach ($link in $links) {
		if($link.tagName -eq "A") {
			if($link.href -Like "*node*-x64.msi"){
			
				$download_url=$link.href.Trim()
				break
			}
		}
	}
	
	# get the version (get text in between v and -x64.msi)
	$i=$download_url.length -1
	while ($download_url[$i] -ne 'v'){ $i= $i -1 }
	
	$len=$download_url.length
	
	$version=$download_url.substring($i+1, $len-($i+1))
	
	$dex=$version.indexof('-')
	
	$version=$version.substring(0,$dex)
	
	# download the file
	#iwr "$base_url\$url_extension" -OutFile $download_name
	
	return @($version,$download_url)
}

function cleanUp($root_dir){

	# remove the node_modules dir if modules were installed
	if ( Test-path "$root_dir\node_modules" ){
		Remove-Item "$root_dir\node_modules" -Force -Recurse
	}

}