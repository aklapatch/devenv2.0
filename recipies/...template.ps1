# package details
$pkgname="name of package"

# package required to extract or run the package
$requires=@("necessary package1", "necessary package2")

# url to scan for the latest package
$base_url="url to scan for latest version of the package"

# extracts the archive and performs other tasks if necessary (gets called by main script)
function arrange($archive_name, $extract_dir){

	#example extraction command (need 7zip in this case)
	7z x "$archive_name" -o "$extract_dir"
	
	# additional tasks can be added if needed	
}

# parses url and returns the version (gets called by main script)
function getVer($base_url){
	
	# parse the $base_url for data
	$ret="parsed version number"
	
	return $ret
}

function cleanUp($root_dir){
	# use the root directory path to clean up excess package files or files that might not be cataloged
	# this function can be left blank if that is not necessary
	
}
	