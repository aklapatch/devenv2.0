# package details
$pkgname="openjdk12"

$global:javaver="12"

# required dependencies
$requires=@("7zip")

# name of the file once downloaded (it will be named that once the main script downloads it)
$download_name="$pkgname.zip"

# source file for function
. $global:recipiedir\recipeFuncs.ps1

# Files to link as a executables (get linked over as .bat files)
$PackageExecFiles = makeTransferList "bin" "bin" "exe" @("javac", "java","jar",
	"javaw", "jdb")
function arrange($fname, $exdir) {

	7z x "$fname" -o"$exdir" | out-null
	Move-Item "$exdir/jdk*/*" $exdir
	Remove-Item "$exdir/jdk*"
}

function getInfo() {
	# source functions
	$scriptDir = "$global:recipiedir\recipeFuncs.ps1"
	. $scriptDir
	
	return getVersionAndLink "https://jdk.java.net/$global:javaver" "*_windows-x64_bin.zip" '-' '_'
}

function cleanUp($root_dir){

	# remove the node_modules dir if modules were installed
	if ( Test-path "$root_dir\node_modules" ){
		Remove-Item "$root_dir\node_modules" -Force -Recurse
	}
}