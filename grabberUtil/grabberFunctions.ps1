# catalogs files and prints them all to a text file 
function catalogFiles($dir_name,$out_file) {

  if ( -Not (Test-Path $dir_name)){
    Write-NewLine "catalogFiles failed since the directory is invalid"
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
  
  Write-NewLine "$concatPaths" >> $out_file
}

# gets available recipies and prints them
function listRecipies {
  
  if (-Not (Test-Path $global:recipiedir)) {
    Write-NewLine "recipiedir is not valid"
    Exit
  }
  
  Write-NewLine "Possible recipies are: "

  $rep_len=$global:recipiedir.Length
  Get-ChildItem $global:recipiedir -Filter *.ps1 | 	Foreach-Object {
    $diff_len=$_.FullName.Length - $rep_len -1
    Write-Output $_.FullName.substring($rep_len+1, $diff_len-4)	
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
    Write-NewLine "Please specify what package you want to $args"
    
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
    Write-NewLine "Recipie for $package not found in $global:recipiedir"

    # print possibilities
    listRecipies
    Exit
  }
}

#==============================================================================
function linkPackageFiles($package){
  # call download and extract script
  $reppath="$global:recipiedir\$($package)$(".ps1")"

  # source the recipies variables
  # the script should extract to a dir called 'packageName'
  . $reppath

  $tmpdir="$global:recipiedir\$($package)"

  # move the files over to the root 
  Write-NewLine "Linking executables with bat files for $package"
  foreach($link in $PackageExecFiles){ # $PackageExecFiles is from the $repath
    $SrcFile = "$tmpdir\$($link.Item1)"
    $DestLink = "$global:fileroot\$($link.Item2)"

    if (Test-Path $SrcFile){
      $null = makeCallerBat $DestLink $SrcFile    
      # make each .bat link
      # assigning to $null mutes output
    } 
    else {
      Write-NewLine "$SrcFile not found, skipping link for that file."
    }
  }

  Write-NewLine "Linking the static files for $package"
  foreach($file in $PackageStaticFiles){
    $SrcFile = "$tmpdir\$($file.Item1)"
    $DestLink = "$global:fileroot\$($file.Item2)"

    if (Test-Path $SrcFile){
      $null = makeHardLink $SrcFile  $DestLink
      # make each hard link
      # assigning to $null mutes output
    } 
    else {
      Write-NewLine "$SrcFile not found, skipping link for that file."
    }
  }

}
# --------------------------------------------------------------#

# installs the specified package
function install($package){

  if (installed $package){
    Write-NewLine "$package is installed"
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
        Write-NewLine "Installing $dep"
        install $dep
      }
    }
  }
  
  $pkgver=0	
  # get file information
  $pkginfo=getInfo
  
  $url=$pkginfo[1]
  $pkgver=$pkginfo[0]
  Write-NewLine "Installing $package version $pkgver"
    
  if ( -Not (Test-Path "$($global:recipiedir)\$($download_name)")) {
    Write-NewLine "Downloading file for $package"
     
    # download file
    (New-Object System.Net.WebClient).DownloadFile($url,"$global:recipiedir\$download_name")
  }
  
  $tmpdir="$global:recipiedir\$($package)"
  $file_path="$global:recipiedir\$($download_name)"
  
  if (Test-Path $tmpdir) {
    Write-NewLine "Removing extraction directory before extraction"
    Remove-Item $tmpdir -Force -Recurse
  }
  
  # extract the files
  Write-NewLine "Arranging files for $package"
  arrange $file_path $tmpdir
  
  #link files
  linkPackageFiles $package

  #output the version of the file
  Write-Output "$pkgver" > "$global:installeddir\$package-version"

  Write-NewLine "$package is installed."
}
# --------------------------------------------------------------#
function remove($package) {	
  # if the $package is all, just delete all the files in the root and
  # remove the cataloged files
  if ( $package -eq "all"){
    Remove-Item "$global:recipiedir\installed\*" -Force
    Remove-Item "$global:fileroot\*" -Recurse -Force

    # TODO remove all extrected directories
    Get-ChildItem $global:recipiedir -Directory | foreach-object {
      
      #don't delete the installed folder
      if ( -Not ($_.Name -eq "installed")){
        Remove-Item -Force -Recurse "$global:recipiedir\$($_.Name)"
      }
    }
    Exit
  }

  $reppath="$global:recipiedir\$($package)$(".ps1")"

  $ExtractedDir = "$global:recipiedir\$($package)"
  
  # source the recipies variables
  # the script should extract to a dir called 'packageName'
  . $reppath

  Write-NewLine "Deleting files for $package"
  foreach ($link in $PackageLinkList) { 
    # Item2 refers to the actual link
    $LinkPath = "$global:fileroot\$($link.Item2)"

    if (Test-Path "$LinkPath"){
      Remove-Item "$LinkPath"
    }
  }
  
  # delete the version file
  Write-NewLine "`nDeleting version file for $package"
  Remove-Item "$global:installeddir\$package-version"  -Force

  # delete Directory where the files were extracted
  Remove-Item -Force -Recurse "$ExtractedDir"
}

# --------------------------------------------------------------#

function installed($package){
  $filespath="$global:recipiedir\installed\$($package)$("-version")"

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
# make a bat file that will call $CalleePath (relative paths)
# also pass the arguments to $CalleePath
function makeCallerBat($CallerPath, $CalleePath){
  # get rid of any '\\', mklink does not work with them
  $CallerPath = $CallerPath.Replace('\\','\')
  $CallerPath = $CallerPath.Replace('.exe','')
  $CalleePath = $CalleePath.Replace('\\','\')

  # delete old link if it is there
  if (Test-Path "$CallerPath"){
    Remove-Item -Force "$CallerPath"
  }

    # find relative path
  $BatDir = Split-Path -Path "$CallerPath"

  # make the directory if it is not there already
  if (-Not (Test-Path "$BatDir")){
    mkdir $BatDir
  }

  $here = Get-Location
  Set-Location $BatDir
  $RelPath = Resolve-Path -Relative "$CalleePath"
  Set-Location $here

  # set the batch file to call the relative path
  Write-Output "@echo off`n%~dp0$RelPath  %*" | Out-File -FilePath "$CallerPath.bat" -Encoding ascii
}

#==============================================================================
# takes in an array of Tuples and links the first item(file), to the last item, the destination
# both args should be absolute paths
function makeHardLink{
  param (
    [string]$SrcFile= $(throw "Source file is required"),
    [string]$LinkDest = $(throw "Link destination is required ")
  )
  # $env:SystemRoot = C:\Windows

  # get rid of any '\\', mklink does not work with them
  $SrcFile.Replace('\\','\')
  $LinkDest.Replace('\\','\')

  # delete old link if it is there
  if (Test-Path "$LinkDest"){
    Remove-Item -Force "$LinkDest"
  }

    # find relative path
  $SrcDir = Split-Path -Path "$LinkDest"

  # make the directory if it is not there already
  if (-Not (Test-Path "$SrcDir")){
    mkdir $SrcDir
  }

  $here = Get-Location
  Set-Location $SrcDir
  $RelPath = Resolve-Path -Relative "$SrcFile"
  $RelPath = $RelPath.Substring(2, $RelPath.Length-2)
  Set-Location $here

  # make the hard link
  $cmdstr = "cmd /c mklink /H $LinkDest $SrcFile"
  Invoke-Expression $cmdstr
}

# =============================================================================
# a wrapper around `makeLink` that just links a file in a different directory
# both directories should be full paths
# all the arguments must not have a trailing backslash
function linkFile($FName, $SrcDir, $DestDir){
  $arg1 = "$SrcDir\$FName"
  $arg2 = "$DestDir\$FName"
  makeLink $arg1  $arg2
}

function Write-NewLine($OutString){
  Write-Output "`n$OutString"
}