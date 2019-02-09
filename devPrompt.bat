@echo off

:: add dirs to path
set "root=%~dp0root"
set "bin=%root%\bin"

set "PATH=%PATH%;%root%;%bin%"

cmd \k