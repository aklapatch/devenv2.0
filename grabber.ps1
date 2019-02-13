# two options, install and remove

$global:operations=@("add","drop","check","list")
$global:recipiedir= -join($PSScriptRoot,"\recipies")
$global:installeddir= -join($global:recipiedir, "\installed")
$global:fileroot= -join($PSScriptRoot,"\root")

# gets available recipies and prints them
function listRecipies {
	
	if (-Not (Test-Path $global:recipiedir)) {
		Write-Output "recipiedir is not valid"
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
		echo
		Write-Output "Usage: $PSCommandPath operation packageName"
		Write-Output "Possible operations: add (retrieves and installs packages)"
		Write-Output "                     drop (uninstalls package)"
		Exit
	}
	
	# check for the second arg or package
	if (  -Not ($operation -in $global:operations) ) {
		Write-Output "Usage:    $PSCommandPath operation packageName"
		Write-Output "Possible operations: add (retrieves and installs packages)"
		Write-Output "                     drop (uninstalls package)"
		Write-Output "                     list (lists installed packages)"
		Write-Output "                     check (checks if the specified package is installed)"
		Exit
	}
	
	# check for the second arg or package
	if ( [string]::IsNullOrEmpty($package) ) {
		Write-Output "Please specify what package you want to $args"
		
		# print possibilities
		listRecipies
		Exit
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

# gets a file if the specified file is not present
function getFile($url, $fname) {

	if ( -Not (Test-Path "$($global:recipiedir)\$($fname)")) {
		echo "Downloading"
		 
		 
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		$wc = New-Object System.Net.WebClient
		$wc.DownloadFile($url, "$($global:recipiedir)\$($fname)")
	}
}

# --------------------------------------------------------------#

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
	if ( -Not (Test-Path "$($global:recipiedir)\$($download_name)")) {
		echo "Downloading"
		 
		 
		# download the file
		$pkgver=getFile $base_url  $download_name
		
		# move the file
		move $download_name $global:recipiedir
	}
	
	$tmpdir="$global:recipiedir\$($package)"
	$file_path="$global:recipiedir\$($fname)"
	
	if (Test-Path $tmpdir) {
		Remove-Item $tmpdir -Force -Recurse
	}
	# extract the files
	arrange $file_path $tmpdir
	
	# use getFiles.bat to catalog the files
	.\getFiles.bat $tmpdir  "$global:recipiedir\installed\$($package)$("_files.txt")"
	
	# move the files over to the root 
	robocopy /MOVE /E /njh /njs /ndl /nc /ns "$tmpdir\" $global:fileroot
	
	# delete leftover folder
	if (Test-Path $tmpdir) {
		Remove-Item "$tmpdir" -Force -Recurse
	}
}
# --------------------------------------------------------------#

function remove($package) {
	
	
	$filespath="$global:recipiedir\installed\$($package)$("_files.txt")"
	
	#
	$reppath="$global:recipiedir\$($package)$(".ps1")"
	
	# source the recipies variables
	# the script should extract to a dir called 'packageName'
	. $reppath

	# get file list
	$files= Get-Content $filespath
	echo "Deleting files for $package"
	foreach ($file in $files) {
		$file=$file.Trim()
		$fpath="$global:fileroot\$($file)"
		Remove-Item $fpath -Force
	}
	
	# run cleanup script
	cleanUp $global:fileroot

	# delete the files list
	del $filespath
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
# SCRIPT MAIN FLOW STARTS HERE #

# go to script's location
cd $PSScriptRoot

# expand path to include necessary tools
$root="$PSScriptRoot\root"
$bin="$root\bin"

$env:Path +=";$root;$bin"

# list option
# lists all installed packages
# iterates through the installed directory and sees which items are installed
if ($args[0] -eq $global:operations[3]) {
	

	if (-Not (Test-Path $global:installeddir)) {
		Write-Output "Installation is not valid"
	}

	$path_len=$global:installeddir.Length
	Get-ChildItem "$global:installeddir" -Filter *_files.txt | 	Foreach-Object {
		$file_str=$_.FullName.substring($path_len +1)
		echo ($file_str -replace '_files.txt',' ')
		
	} 
	Exit
}

# check args and usage
checkArgs $args[0] $args[1]

$operation=$args[0]
$package=$args[1]

# in the 'add' case, check the installed folder to see if the package is installed. 
#If it is installed, then let the user know and exit
# if it is not installed, the recipie will download and extract the files# add these to the path
$root="$PSScriptRoot\root"
$bin="$root\bin"

# add here
echo "adding $root;$bin to the PATH"
$env:Path +=";$root;$bin"
# 'add' case

# to the tmp dir. Then this file will make a list of the files for
# that package with 'getFiles.bat', and check for conflicts.
# that list is put in recipies\installed. Then the files are moved
# from the tmp dir to the 'root' directory
if ( $operation -eq $global:operations[0] ) {

	# the checkArgs functions checks for recipies, so at this point 
	# the recipie exists
	
	# check if a package is installed
	if ( installed $package ) {
		Write-Output "$package is already installed"

		Exit
	}
	
	# check the required array for the package and install dependencies	
	#try {
		install $package
	#} 
	#catch {
	#	echo "Installation Failed"
	#	Exit
	#}
}

# in the 'drop' case, check if the package is installed. If so, 
# then delete all the files on the file list. If not, then let the user know and exit.
if ( $operation -eq $global:operations[1] ) {
	
	if ( -Not (installed $package) ) {
		Write-Output "$package is not installed"

		Exit
	}
	
	remove $package
}

# in the 'check' case, you check the files dir and say if the recipie is installed
if ($operation -eq $global:operations[2] ) {
	
	if ( installed $package ) {
		echo "$package is installed"
		
		Exit
	}
	else {
		echo "$package is not installed"
		
		Exit
	}
}