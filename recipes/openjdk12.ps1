# package details
$pkgname="openjdk12"

$global:javaver="12"

# required dependencies
$requires=@("7zip")

# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.zip"

# Files to link as a executables (get linked over as .bat files)
$PackageExecFiles =@([Tuple]::Create("bin\javac.exe","bin\javac.exe")
              [Tuple]::Create("bin\java.exe","bin\java.exe") )
function arrange($fname, $exdir) {

	7z x "$fname" -o"$exdir" | out-null
	Move-Item "$exdir/jdk*/*" $exdir
	Remove-Item "$exdir/jdk*"
}

function getInfo() {
	# go to the download page and download the first file from top to bottom
	$base_url="https://jdk.java.net/"
	
	$site=iwr -uri "$base_url/$global:javaver"
	$links=$site.parsedhtml.getelementsbytagname("a")
	foreach ($link in $links) {
		if($link.tagName -eq "A") {
			if($link.href -Like "*openjdk-*_windows-x64_bin.zip"){
			
				$download_url=$link.href.Trim()
				break
			}
		}
	}
	
	# get the version (get text in between jdk- and the _ 
	$dex1=$download_url.indexof('-')
	$dex2=$download_url.indexof('_')
	
	$len=$dex2-$dex1
	
	$version=$download_url.substring($dex1+1,$len-1)
	
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