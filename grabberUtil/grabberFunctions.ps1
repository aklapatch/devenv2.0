# catalogs files and prints them all to a text file 
function catalogFiles($dir_name,$out_file) {

	if ( -Not (Test-Path $dir_name)){
		Write-Output "catalogFiles failed since the directory is invalid"
		return
	}

	# clear the output file
	if ( Test-Path $out_file ){
		Remove-Item -Force $out_file
	}
	
	$len=$dir_name.length
	
	$concatPaths = ""
	
	# go through all the files in the directory
	get-childItem $dir_name -recurse -file | foreach-object {
		
		# filter out the dir_name
		$short_path=$_.FullName.substring($len)

		# make the installed dir if is is not there
		if ( -Not(Test-Path $global:installeddir) ){
			mkdir $global:installeddir
		}
		
		# store the Paths to be dumped to file later
		$concatPaths=-join("$concatPaths","`n","$short_path")
	}	
	
	echo "$concatPaths" >> $out_file
}

# gets available recipies and prints them
function listRecipies {
	
	if (-Not (Test-Path $global:recipiedir)) {
		Write-Output "recipiedir is not valid"
		Exit
	}
	
	echo "Possible recipies are: "

	$rep_len=$global:recipiedir.Length
	Get-ChildItem $global:recipiedir -Filter *.ps1 | 	Foreach-Object {
		$diff_len=$_.FullName.Length - $rep_len -1
		echo $_.FullName.substring($rep_len+1, $diff_len-4)	
	} 
}

# --------------------------------------------------------------#
function checkArgs($operation,$package) {
	
	# check for the second arg or package
	if ( [string]::IsNullOrEmpty($operation) ) {
		printUsage
		Exit
	}
	
	# check for the second arg or package
	if (  -Not ($operation -in $global:operations) ) {
		printUsage
		Exit
	}
	
	# check for the second arg or package
	if ( [string]::IsNullOrEmpty($package) ) {
		Write-Output "Please specify what package you want to $args"
		
		# print possibilities
		listRecipies
		Exit
	}
	
	# special case to remove all files
	if ( ($package -eq "all") -and ($operation -eq "drop")){
		return
	}
	
	# check if a package is available
	$reppath= "$global:recipiedir\$($package)$(".ps1")"
	if ( -Not ( Test-Path $reppath) ) {
		Write-Output "Recipie for $package not found in $global:recipiedir"

		# print possibilities
		listRecipies
		Exit
	}
}
# --------------------------------------------------------------#

# installs the specified package
function install($package){

	if (installed $package){
		Write-Output "$package is installed"
		return
	}
	
		# call download and extract script
	$reppath="$global:recipiedir\$($package)$(".ps1")"
	
	# source the recipies variables
	# the script should extract to a dir called 'packageName'
	. $reppath
	
	if ( $requires.Length -gt 0) {  
		Foreach($dep in $requires){
		
			If ( -Not (installed($dep)) ){
				echo "Installing $dep"
				install $dep
			}
		}
	}
	
	$pkgver=0	
	# get file information
	$pkginfo=getInfo
	
	$url=$pkginfo[1]
	$pkgver=$pkginfo[0]
	Write-Output "Installing $package version $pkgver"
		
	if ( -Not (Test-Path "$($global:recipiedir)\$($download_name)")) {
		echo "Downloading file for $package"
		 
		# download file
		(New-Object System.Net.WebClient).DownloadFile($url,"$global:recipiedir\$download_name")
	}
	
	$tmpdir="$global:recipiedir\$($package)"
	$file_path="$global:recipiedir\$($download_name)"
	
	if (Test-Path $tmpdir) {
		Write-Output "`nRemoving extraction directory before extraction"
		Remove-Item $tmpdir -Force -Recurse
	}
	
	# extract the files
	Write-Output "`nArranging files for $package"
	arrange $file_path $tmpdir
	
	# use getFiles.bat to catalog the files
	Write-Output "`nCataloging files for $package"
	catalogFiles $tmpdir  "$global:recipiedir\installed\$($package)$("_files.txt")"
	
	#output the version of the file
	echo "$pkgver" > "$global:installeddir\$package-version"
	
	# move the files over to the root 
	Write-Output "`nCopying over files for $package"
	robocopy /MOVE /E /njh /njs /ndl /nc /ns /np /nfl "$tmpdir\" $global:fileroot
	
	# delete leftover folder
	if (Test-Path $tmpdir) {
		Write-Output "`nDeleting extraction directory"
		Remove-Item "$tmpdir" -Force -Recurse
	}
}
# --------------------------------------------------------------#

function remove($package) {
	
	$filespath="$global:recipiedir\installed\$($package)$("_files.txt")"
	
	#
	$reppath="$global:recipiedir\$($package)$(".ps1")"
	
	
	# if the $package is all, just delete all the files in the root and
	# remove the cataloged files
	if ( $package -eq "all"){
		Remove-Item "$global:recipiedir\installed\*"
		Remove-Item "$global:fileroot\*" -Recurse -Force
		
		Exit
	}
	
	# source the recipies variables
	# the script should extract to a dir called 'packageName'
	. $reppath

	# get file list
	$files= Get-Content $filespath
	
	$other_files=""
	# get a list of all other to make sure duplicate files are not deleted
	Get-ChildItem $global:installeddir -Filter *_files.txt | foreach-object {
		
		# don't count the $package file
		if (-Not ($_.Name -Like "$package*") ){
			
			$other_files+=$(Get-Content $_.FullName)
		}
	}	

	Write-Output "`nDeleting files for $package"
	foreach ($file in $files) {
		$file=$file.Trim()
		$fpath="$global:fileroot\$($file)"

		# only delete files that are not duplicates
		if ( -Not( $other_files.contains($file) )){

			Remove-Item -force $fpath 
		}
	}
	
	# delete the files list and the version file
	Write-Output "`nDeleting version file and file record file for $package"
	Remove-Item $filespath  -Force
	Remove-Item "$global:installeddir\$package-version"  -Force

	# removing cached download file
	if (Test-Path "$global:installeddir\$download_name"){
		Write-Output "`nDeleting the cached download file."
		Remove-Item "$global:installeddir\$download_name"
	}
	
	# run cleanup script
	Write-Output "`nRunning cleanup function"
	cleanUp $global:fileroot
}

# --------------------------------------------------------------#

function installed($package){
	$filespath="$global:recipiedir\installed\$($package)$("_files.txt")"

	# package is installed
	if ( Test-Path $filespath ) {
		return $true
	}
	return $false
}

# --------------------------------------------------------------#

function getLocalVersion($package) {
  $version = Get-Content "$global:installeddir\$package-version"
  return getIntFromVer($version)
}

# --------------------------------------------------------------#
function getRemoteVersion($package) {
  # call download and extract script
	$reppath="$global:recipiedir\$($package)$(".ps1")"
	
	# source the recipies variables
	# the script should extract to a dir called 'packageName'
  . $reppath
  
  $version,$url = getInfo $base_url

  return getIntFromVer($version)
}
# --------------------------------------------------------------#
function getIntFromVer($StringVersion){
  $StringVersion = $StringVersion.replace(".", "")
  return [convert]::ToInt32($StringVersion,10)
}

#==============================================================================
# takes in an array of Tuples and links the first item(file), to the last item, the destination
# both args should be absolute paths
function makeLink{
	param (
		[string]$SrcFile= $(throw "Source file is required"),
		[string]$LinkDest = $(throw "Link destination is required ")
	)
	# $env:SystemRoot = C:\Windows

	# you could use Resolve-Path -Relative to get relative paths if need be https://stackoverflow.com/questions/12396025/how-to-convert-absolute-path-to-relative-path-in-powershell
	# maybe Get-Location would be helpful
	Write-Output "Linking $SrcFile to $LinkDest"

	# find relative path
	$here = Get-Location
	Set-Location (get-item "$LinkDest").Directory
	$RelPath = Resolve-Path -Relative $SrcFile
	Set-Location $here

	# delete old shortcut if it is there
	if (Test-Path "$LinkDest.lnk"){
		Remove-Item -Force "$LinkDest.lnk"
	}
	# delete old link if it is there
	if (Test-Path "$LinkDest"){
			Remove-Item -Force "$LinkDest"
	}

	# make shortcut
	$SShell = New-Object -ComObject WScript.Shell
	$Link = $SShell.CreateShortcut("$LinkDest.lnk")
	$Link.TargetPath = "$SrcFile" # this needs! quotes
	$Link.Save()

	Rename-Item -Path "$LinkDest.lnk" "$LinkDest"  -Force
}

# =============================================================================
# a wrapper around `makeLink` that just links a file in a different directory
# both directories should be full paths
function linkFile($FName, $SrcDir, $DestDir){
	$arg1 = "$SrcDir\$FName"
	$arg2 = "$DestDir\$FName"
	makeLink $arg1  $arg2
}

