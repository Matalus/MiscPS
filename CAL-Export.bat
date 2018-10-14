FOR /F "tokens=*" %%A IN (\\vault\tech3\Scripts\Matt\ProvisionedVMS.txt) DO ( 
ECHO %%A
PSEXEC \\%%A REG EXPORT HKLM\SOFTWARE\Microsoft\MSLicensing\Store\LICENSE000 C:\Temp\%%A.reg /y
XCOPY /Y \\%%A\C$\Temp\%%A.reg "\\vault\tech3\Scripts\Reference Files\CALTEMP\"
)