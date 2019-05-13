
$global:operations=@("add","drop","check","list","clean","update")
$global:recipiedir= -join($PSScriptRoot,"\recipies")
$global:installeddir= -join($global:recipiedir, "\installed")
$global:fileroot= -join($PSScriptRoot,"\root")
$global:funcPath=".\grabberUtil\grabberFunctions.ps1" # a path to a script with extra functions

 #-----------------------------------------------------------------------------
 function printUsage {
	Write-Output "`nUsage:    $PSCommandPath operation packageName"
	Write-Output "Possible operations: add (retrieves and installs packages)"
	Write-Output "                     drop (uninstalls package)"
	Write-Output "                     list (lists installed packages)"
	Write-Output "                     check (checks if the specified package is installed)"
	Write-Output "                     clean (removed cached download files)"
	Write-Output "                     update (updates the specified program to a newer version if available)"
}

# SCRIPT MAIN FLOW STARTS HERE #===============================================

# go to script's location
cd $PSScriptRoot

# get the functions necessary for the package manager
. $global:funcPath

# expand path to include necessary tools
$root="$PSScriptRoot\root"
$pathExtensions=";$root;$root\bin;$root\usr\bin;$root\mingw64\bin"

$env:Path +="$pathExtensions"

# in the clean case, source every recipie and delete every download name from that recipie
if ($args[0] -eq $global:operations[4]){
	# get each script and delete its file
	Get-ChildItem $global:recipiedir -Filter *.ps1 | foreach-object {
		
		# source script if it is there
		if (Test-Path $_.FullName){
			. $_.FullName
		}
		
		# delete downloaded files if it is there
		if (Test-Path "$global:recipiedir\$download_name" ){
			
			Remove-Item "$global:recipiedir\$download_name"
		}
	}
	Exit
}

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
		$item=($file_str -replace '_files.txt','')
		$version=Get-Content -Path "$global:installeddir\$item-version"
		Write-Output "$item $version"
		
	} 
	Exit
}

# check args and usage
checkArgs $args[0] $args[1]

$operation=$args[0]
# get all packages in argument list
$packages=$args[1.. ($args.length-1)]

# in the 'add' case, check the installed folder to see if the package is installed. 
#If it is installed, then let the user know and exit
# if it is not installed, the recipie will download and extract the files# add these to the path
$root="$PSScriptRoot\root"
$bin="$root\bin"

# add installed tools to path
$env:Path +=";$root;$bin"

foreach ($package in $packages){

	checkArgs $operation $package

	try {
		# ADD CASE
		# check for conflicts.
		# that list is put in recipies\installed. Then the files are moved
		# from the tmp dir to the 'root' directory
		if ( $operation -eq $global:operations[0] ) {

			# the checkArgs functions checks for recipies, so at this point 
			# the recipie exists
			
			# check if a package is installed
			if ( installed $package ) {
				Write-Output "$package is already installed"
			}
			
			# check the required array for the package and install dependencies	
			install $package

			continue
		}

		# in the DROP CASE, check if the package is installed. If so, 
		# then delete all the files on the file list. If not, then let the user know and exit.
		if ( $operation -eq $global:operations[1] ) {
			
			# all is a special case to delete all the installed files
			if ( $package -eq "all"){
				# delete all files
				Remove-Item -Force -Recurse "$global:fileroot\*"
				# delete installation files
				Remove-Item -Force "$global:installeddir\*"
			
			}
			
			elseif ( -Not (installed $package) ) {
				Write-Output "$package is not installed"
				
			} else {
			
				remove $package
			}

			continue
		}

		# in the CHECK CASE, you check the files dir and say if the recipie is installed
		if ($operation -eq $global:operations[2] ) {
			
			if ( installed $package ) {
				echo "$package is installed"
			}
			else {
				echo "$package is not installed"
			}
			continue
		}

		# UPDATE CASE
		# use the getinfo version to check if the version that you have now is < the
		# remote version. Then install the new version
		if ($operation -eq $global:operations[5]) {

			if (-Not(installed $package)){
				Write-Output "$package is not installed"
				Exit
			}

			# get the package local version
			$LocalVer = getLocalVersion($package)

			Write-Output "Local version of $package is $LocalVer"

			$RemoteVer = getRemoteVersion($package)

			Write-Output "Remote version of $package is $RemoteVer"

			# if remote version is newer, drop older and get newer
			if ($RemoteVer -gt $LocalVer) {
				
				Write-Ouput "Updating $package to version $RemoteVer"

				remove($package)

				install($package)
			}
			continue
		}
	} catch {
		echo "$operation failed for $package!"
	}
}