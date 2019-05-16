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
  if (Test-Path "$PSScriptRoot\$script"){
    Write-Output "`nRemoving old directory."
    Remove-Item -Force -Recurse "$PSScriptRoot\$script"
  }
  
  # call the arrange function
  Write-Output "`nArranging files for $script"
  arrange $download_name $script
}

elseif( $function = "getInfo" ) {
    # call getInfo to get URL and version
  $info=getInfo $base_url
  $ver=$info[0]
  $url=$info[1]
  
  # output version
  Write-Output "Output version is $ver"
  
  #debug url
  Write-Output "The url is $url"
}