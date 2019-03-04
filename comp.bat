@echo off
if "%1" == "" goto :empty
if "%1" == "/?" goto :help

if not exist %1.asm goto :error

tasm /l /t /m %1.asm

if not exist %1.obj goto :errorobj
tlink /t %1.obj

goto :eof
:help
echo This script compiles .asm programm
echo.
echo Use this script as follow:
echo comp filename
goto :eof
:empty
echo The argument is empty. Please, check the help
echo comprun /?
goto :eof
:errorobj
echo File %1.obj does not exists
goto :eof
:error
echo File %1.asm does not exists
:eof
