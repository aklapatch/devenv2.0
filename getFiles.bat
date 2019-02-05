@echo off
:: gets a list of all the files recursively in a directory
:: %1 is the directory to examine 
:: %2 is the output file

if "%1"=="" (
	echo Usage: %0 folderToScan outputFile
	goto :eof
)

if "%2"=="" (
	echo Usage: %0 folderToScan outputFile
	goto :eof
)

set "arg_dir=%~dpnx1"

if not exist %arg_dir% (
	echo %arg_dir% not found!
	goto :eof
)

set "outfile=%~dpnx2"
echo files: > %outfile%

cd %arg_dir%

for /r %%a in (*) do call :filter_out %%a

cd %~dp0

goto :eof

:filter_out
setlocal enabledelayedexpansion

set tmp=%1 & call set tmp=%%tmp:%arg_dir%=%%

echo %tmp:~1,500% >> %outfile%

endlocal
goto :eof