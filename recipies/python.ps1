# package details
$pkgname="python"

# required dependencies
$requires=@("7zip")

#https://www.python.org/downloads/
# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.zip"

function arrange($fname, $exdir) {

	7z x "$($fname)" -o"$exdir"  | out-null

	# get the version number again
	$ver = getInfo

	$ver = $ver[0]

	$ver = $ver.substring(0,3)

	$ver = $ver -replace '[.]','' #take out the .'s
	
	$filename = "$exdir\python$ver._pth"
	# add a path to the python._pth variable
	(Get-Content $filename) | 
    Foreach-Object {
        $_ # send the current line to output
        if ($_ -eq ".") 
        {
            #Add Lines after the selected pattern 
            "Scripts`nLib"
        }
	} | Set-Content $fileName

	# extract libraries into the library directory
	7z x "$exdir\python$ver.zip" -o"$exdir\Lib" | Out-Null
	
	# remove the compressed modules that were extracted ^^^ there
	Remove-Item "$exdir\python$ver.zip" -Force 

	$script = "$exdir\get-pip.py"
	
	Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "$script"

	# install pip
	Write-Output "`nInstalling pip `n"
	$command = "$exdir\python.exe $script"
	iex $command

	# remove get-pip script
	Remove-Item -Force "$script"
	
	# copy pip to extraction directory
	Move-Item "$exdir\Scripts\*" "$exdir\"
}

function getInfo() {
	# go to the download page and download the first file from top to bottom
	# that has the right pattern
	
	$base_url="https://www.python.org/downloads/"

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
	$page=(New-Object System.Net.WebClient).DownloadString("$base_url")
	
	$search_str = ">Download Python "
	$dex=$page.IndexOf($search_str)
	$dex=$page.IndexOf($search_str,$dex+1)
	$endDex = $page.IndexOf('</a>', $dex)
	# pull out version
	$startPos = $dex + $search_str.length
	$version=$page.Substring($startPos,$endDex-$startPos)

	#https://www.python.org/ftp/python/3.7.3/python-3.7.3-embed-amd64.zip
	
	return @($version,"https://www.python.org/ftp/python/$version/python-$version-embed-amd64.zip")
}

function cleanUp($root_dir){
	# remove python libraies
	Remove-Item "$global:fileroot\Lib" -Recurse -Force
	Remove-Item "$global:fileroot\Scripts" -Recurse -Force
}