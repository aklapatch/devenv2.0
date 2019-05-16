# package details
$pkgname="cmake"

# required dependencies
$requires=@("7zip")

# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.zip"

# Files to link as a executables (get linked over as .bat files)
$PackageExecFiles =@([Tuple]::Create("bin\cmake.exe","bin\cmake.exe")
              [Tuple]::Create("bin\cmake-gui.exe","bin\cmake-gui.exe") )

# Files to make hard links for (preferably headers and libraries)
$PackageStaticFiles = @()

function arrange($fname, $exdir) {

	7z x "$($fname)" -o"$exdir"  | out-null
	
	# move files out from versioned folder
	Get-ChildItem -Path "$exdir\cmake-*win64*\*" -Force | Move-Item -Destination "$exdir"	

	# remove directory
	Remove-Item -Force -Recurse "$exdir\cmake-*win64*"
}

function getInfo() {
	# go to the download page and download the first file from top to bottom
	# that has the right pattern
	
	$base_url="https://cmake.org/download/"

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	$site=Invoke-WebRequest -uri $base_url
	$links=$site.parsedhtml.getelementsbytagname("a")
	foreach ($link in $links) {
		if($link.tagName -eq "A") {
			if($link.href -Like "*cmake-*-win64-x64.zip"){
			
				$download_url=$link.href.Trim()
				break
			}
		}
	}
	
	# get the version (get text in between jdk- and the _ 
	$dex1=$download_url.indexof('-')
	$dex2=$download_url.indexof('-win')
	
	$len=$dex2-$dex1
	
	$version=$download_url.substring($dex1+1,$len-1)
	
	return @($version,$download_url)
}

function cleanUp($root_dir){
	
}