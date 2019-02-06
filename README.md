# Devenv2.0


## Plan
#### Overall
Make a tool to fetch binaries for programs and install them in a /bin /lib /include structure like linux.

So we have `grabber` which goes into the `recipies` folder and finds the recipie (like python, perl, gcc, etc) that you want, and downloads it. Then it extracts those files to a temporary directory, catalogs them for later. If you want to delete the tool later, it will delete the files that it cataloged

#### Recipies
There will be a `.ps1` file that, when run by the `grabber.ps1` file will get, extract and install the recipie specified by the user.

The grabber script will run the `packageName.ps1` script to install the package.