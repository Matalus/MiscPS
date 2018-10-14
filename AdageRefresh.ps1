$div=$args[0]

#Kills previous loggers if running.
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"

#Gets time stamp and creates string name for log file
$stamp=(Get-Date -Format MMddyyyy_hh.mmtt)
$log="Refresh_"+$stamp

Get-ChildItem c:\adbatch\log\*.log | Move-Item -Destination c:\adbatch\log_archive\

Start-Transcript -path c:\adbatch\log\$log.log  -append

write-host "Previous Log Archived"
write-host ""
Write-Host "Performing Script Backup... please wait"

$LOCAL=$env:COMPUTERNAME

#Backs up Local diretories to Network Storage

#Cleans up and backs up AZ
IF($LOCAL -eq 'adaz')
{
Get-ChildItem \\USERDATA\helpdesk\AdageRefresh\$div | Remove-Item -Force -Recurse
Copy-Item \\$LOCAL\c$\adbatch -Destination \\USERDATA\helpdesk\AdageRefresh\$div
}

#Cleans up and backs up DEN
IF($LOCAL -eq 'adden')
{
Get-ChildItem \\USERDATA\helpdesk\AdageRefresh\$div | Remove-Item -Force -Recurse
Copy-Item \\$LOCAL\c$\adbatch -Destination \\USERDATA\helpdesk\AdageRefresh\$div
}

Write-Host ""
Write-Host -ForegroundColor Green "Script and Log Backup Complete"
Write-Host ""

Start-Sleep -s 1

Write-Host -ForegroundColor Red "Starting Refresh"
Write-Host ""
Write-Host "Opening Log"

#opens log
c:\windows\system32\Trace32.exe C:\adbatch\log\refresh.log

#defines adage directories for string concantenation
$ADAGEDIR1 = adage_25\adimages
$ADAGEDIR2 = adage_25\SFC_REPORTS
$ADAGEDIR3 = adage_25\ADIMAGES\ORACLE
$ADAGEDIR4 = adage_25\ADAGE2PBAPPS

#Parse Text File and BEGIN LOOP EXECUTION
ForEach-Object ($HOSTPATH in Get-Content c:\adbatch\hosts.txt)
{

Write-Host ""
Write-Host "Copying Files to $HOSTPATH\$ADAGEDIR..."
Write-Host

Get-ChildItem $HOSTPATH\$ADAGEDIR1 | Remove-Item -Force -Recurse

PSFILE \\adageprog c:\vol\adage\Adage_Prod\adage_25\adimages




















