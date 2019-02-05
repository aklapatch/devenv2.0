# Devenv2.0


## Plan
#### Overall
Make a tool to fetch binaries for programs and install them in a /bin /lib /include structure like linux.

So we have `npam.bat` which goes into the `recipies` folder and finds the recipie (like python, perl, gcc, etc) that you want, download it, and install it. Then it extracts those files to a temporary directory, catalogs them for later. If you want to delete the tool later, it will delete the files that it cataloged

#### Recipies
There will be a `.bat` file that, when run by the `npam.bat` file will get, extract and install the recipie specified by the user.