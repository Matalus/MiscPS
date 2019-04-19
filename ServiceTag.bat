@ECHO OFF
ECHO Shamrock Foods - Information Services Dept.
ECHO ServiceTag Inventory
IF NOT EXIST c:\windows\temp\servicetag.txt (
echo running query...
echo %computername% >> c:\windows\temp\servicetag.txt
echo %username% >> c:\windows\temp\servicetag.txt
wmic /append:c:\windows\temp\servicetag.txt /namespace:\\root\cimv2 path win32_bios get serialnumber
echo ------------------------------- >> c:\windows\temp\servicetag.txt
type c:\windows\temp\servicetag.txt >> \\userdata.corpdomain.com\entbpi$\hardwarequery\servicetaginventory.txt
) ELSE (
echo File Exists Exiting
)