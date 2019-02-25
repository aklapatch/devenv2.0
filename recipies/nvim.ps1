# package details
$pkgname="nvim"

# required dependencies
$requires=@("7zip")

#https://www.7-zip.org/a/7z1806-x64.msi"https://julialang-s3.julialang.org/bin/winnt/x64/1.1/julia-1.1.0-win64.exe
$base_url="https://github.com/neovim/neovim/releases/latest"
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.zip"

function arrange($fname, $exdir) {

	# extract the files 
	7z x $fname -o"$exdir"
	
	# move to the 'nvim' directory
	Move-Item "$exdir\Neovim\*" "$exdir\"

	# Remove the old Neovim folder
	Remove-Item "$exdir\Neovim" -Recurse 
}

function getInfo($base_url) {
	# go to the download page and download the first file from top to bottom
	# that has a certain pattern
	# https://github.com/neovim/neovim/releases/latest
	
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
	$page=(New-Object System.Net.WebClient).DownloadString("$base_url")
	
	$dex=$page.IndexOf("/nvim-win64.zip")
	# pull out version
	$version=$page.Substring($dex-5,5)

	$MaVer=$version.Substring(0,1)
	$MiVer=$version.Substring(2,1)
	$Rev=$version.Substring(4,1)

	return @($version,"https://github.com/neovim/neovim/releases/download/v$MaVer.$MiVer.$Rev/nvim-win64.zip")
}

function cleanUp($root_dir){

}