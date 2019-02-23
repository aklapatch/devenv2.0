# calls the test functions in the specified recipie.
# it sources the script first, then runs through the specified function

$script=$args[0]
$function=$args[1]

$dir=$PSScriptRoot

if ( -Not (Test-Path "$script.ps1")) {
	Write-Output "$script.ps1 not found in current directory."
	Exit
}

# source specified script
. .\"$script.ps1"

if ( $function = "arrange" ){
	
	# call getInfo to get URL and version
	$info=getInfo $base_url
	$ver=$info[0]
	$url=$info[1]
	
	# output version
	Write-Output "Output version is $ver"
	
	#debug url
	Write-Output "The url is $url"
	
	if ( -Not (Test-Path $download_name)) {
		echo "Downloading file for $script"
		 
		# download file
		(New-Object System.Net.WebClient).DownloadFile($url,"$PSScriptRoot\$download_name")
	}
	
	# remove old directory
	if (Test-Path $script){
		Remove-Item -Force -Recurse $script
	}
	
	# call the arrange function
	arrange $download_name $script
}

if( $function = "getInfo" ) {
		# call getInfo to get URL and version
	$info=getInfo $base_url
	$ver=$info[1]
	$url=$info[0]
	
	# output version
	Write-Output "Output version is $ver"
	
	#debug url
	Write-Output "The url is $url"
}

if ( $function = "cleanUp" ) {

	if (Test-Path $script){
	
		# test cleanup function
		cleanUp $script
		Exit
	}

	# call getInfo to get URL and version
	$info=getInfo $base_url
	$ver=$info[1]
	$url=$info[0]
	
	# output version
	Write-Output "Output version is $ver"
	
	#debug url
	Write-Output "The url is $url"
	
	if ( -Not (Test-Path $download_name)) {
		echo "Downloading file for $script"
		 
		# download file
		(New-Object System.Net.WebClient).DownloadFile($url,"$PSScriptRoot\$download_name")
	}
	
	# call the arrange function
	arrange $download_name $script
		
	# test cleanup function
	cleanUp $script
}
	
	
	
	
	