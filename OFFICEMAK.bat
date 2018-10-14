
REM Loops Command through multiple servers
CLS
ECHO Loop Script.bat
ECHO.
ECHO Batch Installs MAK key and activates Office.
ECHO.
set /p PASSWORD= Enter Network Password....[ 
cls

ECHO.
PSEXEC @mak.txt -u "%USERDOMAIN%\%USERNAME%" -p "%PASSWORD%" OFFICEMAK.bat

SET PASSWORD=null

ECHO.
ECHO.
ECHO Password Cache Purged Variable Reset to Null
PAUSE

