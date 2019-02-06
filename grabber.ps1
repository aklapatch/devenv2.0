# two options, install and remove

$operations= "add", "drop"
$recipiedir= "recipies\"

# lists available recipies and prints them
function checkRecipies {
	
}

# --------------------------------------------------------------#
function checkArgs {
	$var=$args[1]
	
	# check for the second arg or package
	if ( -Not ($args[0] -in $global:operations) ) {
		Write-Output "Usage: $PSCommandPath operation packageName"
		Write-Output "Possible operations: add (retrieves and installs packages)"
		Write-Output "                     drop (uninstalls package)"
		Exit
	}
	
	# check for the second arg or package
	if ( [string]::IsNullOrEmpty($args[1]) ) {
		Write-Output "Please specify what package you want to $args"
		Exit
	}
	
	# check if a package is available
	if ( -Not ( Test-Path (-join($global:recipiedir,$var)) -PathType Leaf) ) {
		Write-Output "Recipie for $var not found."
		Exit
	}
}
# --------------------------------------------------------------#
### SCRIPT MAIN FLOW STARTS HERE ###

# check args and usage
checkArgs $args[0] $args[1]

# go to script's location
cd $PSScriptRoot


$operation=$args[0]
$package=$args[1]

Write-Output $args[0]

if ($operation -eq "add"){
	

	
	

}
