# Grabber

## Overall
Make a tool to fetch binaries for development programs and install them in a /bin /lib /include structure like linux.

## Implementation details 

### main script
Parses args, and sources the recipe for a package from the recipes directory. It also executes the `arrange` and `cleanUp` functions in those recipies when those packages are installed and removed

#### installing (add command)
Source recipe for package, use the url variable and the start and end variables (in the recipe) to find the link to the binary to download. 

The URL in the script should be the url of the download page, ad the start and end variables will allow the main script to find the URL of the latest version of the package. This means that the recipies do not have to be updated unless the download page for the package changes in layout or in web address.

The main script then downloads the package, and runs the arrange function in the recipe. That arrange function should take two arguments, a filename to extract, and a directory to extract into. Other tasks can be inserted in that function if needed. Arrange should also return the version number of the package

At that point, the main script catalogs the version of the package and the files the the temporary extraction directory. The files are cataloged in `recipies\installed\$package_name_files.txt` and the version can be cataloged in `recipies\installed\$packageName-version`.

Then, the files are copied from the temporary director to the root directory.

#### uninstalling (drop command)
The main script will delete all the files that were cataloged in `$package_name_files.txt` and execute the `cleanUp` function from that package's recipie. Then delete the `$package_name_files.txt` file and the `$package_name-version` file.

### Recipie requirements
Each recipie needs to have a couple things. Variable conventions are influenced by Arch Linux's makepkg.

+ A `$base_url` variable
	This is the url which the main script searches to find the latest version of the user-specified package.

+ A `$requires` variable (an array of other package names that that recipie requires to be used or extracted.)
+ An `$arrange` function
	This function should take two parameters, the first is the path of an archive to extract and the directory to extract that archive into.
+ A `cleanUp` function that performs cleanup tasks, such as deleting files that may have not been initially cataloged, such as additional npm or pip packages.
+ A `$download_name` variable that specifies the name of the file that the `getFile` function downloads
+ A `getInfo` function that gets the url of the latest version of the package and returns the package version as a string, and the latest url as a string (in an array).

There are some examples in the `recipe` directory that will probably be more helpful that this explanation.