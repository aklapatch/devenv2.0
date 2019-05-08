@echo off

:: add dirs to path
set "root=%~dp0root"
set "bin=%root%\bin"
set mingw64="%root%\mingw64\bin"
set usr="%root%\usr\bin"

set "PATH=%usr%;%mingw64%;%root%;%bin%;%PATH%"

cmd \k