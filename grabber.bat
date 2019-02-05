:: two options, install and remove

:: just in case
cd "%~dp0"

if "x%1"=="xinstall" (
	
	:: no second arg given
	if "x%2"=="x" echo "No program was specified for installation" & goto :eof
	
	goto :install
)

if "x%1"=="xremove" (
	
	:: no second arg given
	if "x%2"=="x" echo "No program was specified for removal" & goto :eof

	:: delete the files that were installed
	:: find the text file that matches the target and 
	:: delete the files in it
	goto :delete
)

:: run the install batch file
:install
call "recipies\%2.bat"

:: catalog the files extracted
getFiles.bat "recipies\%2" "recipies\%2_files.txt"

:: move the files over to the root 
robocopy /MOV /MIR "recipies\%2\" "root\"

:: delete the extraction dir
rmdir /s /q "recipies\%2"
goto :eof

:: deletes files specified in the text document
:delete
for /F "tokens=*" %%a in ("recipies\%2_files.txt") do del "%~dp0root\%%a"

:: delete the file that houses the files
del "recipies\%2_files.txt"

goto :eof