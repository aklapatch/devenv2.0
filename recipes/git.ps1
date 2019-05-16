# package details
$pkgname="git"

# packages that this one needs to install it
$requires=@("7zip")
#https://git-scm.com/download/win
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.exe"


# list of exectuable to link
$Dir = "mingw64\bin"
$PackageExecFiles = @([Tuple]::Create("bin\git.exe","bin\git.exe")
                      [Tuple]::Create("$Dir\curl.exe","bin\curl.exe") 
                      [Tuple]::Create("\git-bash.exe","\git-bash.exe")
                      [Tuple]::Create("bin\sh.exe","bin\sh.exe")
                      [Tuple]::Create("bin\bash.exe","bin\bash.exe"))

$PackageStaticFiles = @()
function arrange($fname, $exdir) {

  # we just need to move the files into the tmp dir
  7z x "$fname" -o"$exdir" | out-null
}

function getInfo() {
  # go to the download page and download the first file from top to bottom
  # that has a certain pattern
  $base_url="https://git-scm.com/download/win"
  
  $site=Invoke-WebRequest "$base_url"
  $links=$site.links
  foreach ($link in $links) {
    if($link.href -Like "*PortableGit*64*7z.exe"){
      
      $url_extension=$link.href
      break
    }
  }
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  # pull out version
  $startDex=$url_extension.indexOf("leGit-") + 6
  $EndDex = $url_extension.indexOf("-64-bit.7z.exe")
  $version=$url_extension.substring($startDex, $EndDex - $startDex)
  
  # returns both values
  $version
  $url_extension
}

function cleanUp($root_dir){

}