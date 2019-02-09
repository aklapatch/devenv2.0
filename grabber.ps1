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

# gets a file if the specified file is not
function getFile($url, $fname) {
	
	if ( -Not (Test-Path "$($global:recipiedir)\$($fname)")) {
		echo "Downloading"
		iwr $url -Outfile "$($global:recipiedir)\$($fname)"
	}
}

# --------------------------------------------------------------#

function install($package){
	
		# call download and extract script
	$reppath="$global:recipiedir\$($package)$(".ps1")"
	
	# source the recipies variables
	# the script should extract to a dir called 'packageName'
	. $reppath
	
	# download the file
	getFile $url  $fname
	
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
	robocopy /MOVE /E "$global:recipiedir\$($package)\" $global:fileroot
}
# --------------------------------------------------------------#

function remove($package) {
	
	
	$filespath="$global:recipiedir\installed\$($package)$("_files.txt")"

	# get file list
	$files= Get-Content $filespath
	foreach ($file in $files) {
		$file=$file.Trim()
		echo "$global:fileroot\$($file)"
		Remove-Item "$global:fileroot\$($file)" -Force
	}

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

# list option
# lists all installed packages
# iterates through the installed directory and sees which items are installed
if ($args[0] -eq $global:operations[3]) {
	

	if (-Not (Test-Path $global:installeddir)) {
		Write-Output "Installation is not valid"
	}
	
	echo "You have these packages installed: "

	$rep_len=$global:recipiedir.Length
	Get-ChildItem $global:recipiedir -Filter *_files.txt | 	Foreach-Object {
		$diff_len=$_.FullName.Length - $rep_len -1
		echo $_.FullName.substring($rep_len+1, $diff_len-4)	
	} 
	Exit
}

# check args and usage
checkArgs $args[0] $args[1]

$operation=$args[0]
$package=$args[1]

# in the 'add' case, check the installed folder to see if the package is installed. 
#If it is installed, then let the user know and exit
# if it is not installed, the recipie will download and extract the files
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
	
	install $package
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