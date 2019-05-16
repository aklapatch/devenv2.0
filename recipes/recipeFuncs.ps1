# useful functions that make recipe creation/automation easier

# returns a list of files with the $FileExtension extension that are in $dirname
# $FileExtension must have no '.' at the beginning for this function to return anything
function getFilesWithExtIn($dirName, $FileExtension){
    # print error message and return empty array
    if (-Not (Test-Path $dirName)){
        Write-Output " $dirname does not exist!"
        return @()
    }

    $FileList = @() # ready array for return

    $searchExt = "*.$FileExtension"

	Get-ChildItem $dirName -Filter $searchExt | foreach-object {
		
        # append filenames to list
        $FileList += $_
        # may need to use $_.FullName later if this does not work
    }
    
    return $FileList
}
#==============================================================================
#Gets the latest tag from a github download/release page
# base_url is the download page, and $Search
function getLatestGithubTag($base_url) {

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
	$page=(New-Object System.Net.WebClient).DownloadString("$base_url")
	
	$SearchStr = '/releases/tag/'
	$dex=$page.IndexOf($searchStr) + $searchStr.length
	$endDex = $page.IndexOf('>',$dex) - 1;
	# pull out version
	
	$version=$page.Substring($dex,$endDex - $dex)

	return $version
}

#==============================================================================
# get the version of the file from a github release page, by searching for a
# filename matching $SearchStr. RegEx may be used in $SearchStr
# $startChar should be the character right before the version number (in the filename)
# $endChar should be the character right after the version number (in the filename)
# this function should not be called with funcName(args,moreArgs). That does not work
# for some reason.
function getVersionGithubRelease($base_url, $SearchStr,$startChar, $endChar){
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
    $page=(New-Object System.Net.WebClient).DownloadString("$base_url")
    
    $mark= ($page | Select-String $searchStr ).Matches.Index # get the first match

    # pull out the version number
	$mark = $page.IndexOf($startChar,$mark) +1
	$endMark = $page.IndexOf($endChar,$mark)

	# pull out version	
	return $page.Substring($mark,$endMark - $mark)
}
#==============================================================================
# Returns a link from $baseUrl 's website. That link will be Like $SearchStr 
# (use wildcards to do fuzzy matching), and from that URL that matches $SearchStr,
# The version will be extracted from the text between $StartChar and $EndChar
function getVersionAndLink($BaseUrl, $SearchStr, $StartChar, $EndChar){
    	# go to the download page and download the first file from top to bottom	
	$site=iwr -uri "$BaseUrl"
    $links=$site.parsedhtml.getelementsbytagname("a")
    $download_url = ""
	foreach ($link in $links) {
		if($link.tagName -eq "A") {
			if($link.href -Like $SearchStr){
			
				$download_url=$link.href.Trim()
				break
			}
		}
    }
    
    if ($download_url -eq ""){ # exit if link was not found
        Write-Output "Found no link from $BaseUrl matching $SearchStr"
        return @(0,"")
    }
	
	# get the version (get text in between jdk- and the _ 
	$dex1=$download_url.indexof('-') + 1
	$dex2=$download_url.indexof('_',$dex1)
	
	$version=$download_url.substring($dex1,$dex2 - $dex1)
	
	return @($version,$download_url)
}
#==============================================================================
# returns an array of tuples as such @(("$Origdir\$FileList[0].$Extension,$DestDir\$FileList[0].$Extension" ), ("$Origdir\$FileList[1].$Extension,$DestDir\$FileList[1].$Extension" )
# and so on. 
# Files SHOULD NOT have extensions. This function assumes
function makeTransferList($OrigDir, $DestDir, $Extension, $FileList){
    $output = @()
    foreach($File in $FileList){
        $output += [Tuple]::Create("$OrigDir\$File.$Extension","$DestDir\$File.$Extension")
    }
    return $output
}