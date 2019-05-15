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