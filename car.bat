@echo off
if "%1" == "" goto :empty
if "%1" == "/?" goto :help
if exist %1
tasm /m /l %1.asm /l
tlink /t %1.obj
%1.com
goto :eof
:help
echo This script compiles and run .asm programm
echo.
echo Use this script as follow:
echo comprun filename
goto :eof
:empty
echo The argument is empty. Please, check the help
echo comprun /?
goto :eof
:eof
