cls
Write-host Revokes Per Device TS CALs
$ISSUEDTO = Read-Host Enter Host Name

$QUERY = (gwmi -ComputerName tslice WIN32_TSISSUEDLICENSE | where { $_.keypackid -eq 11 } `
 | where { $_.sIssuedToComputer -eq $ISSUEDTO})

 $QUERY | select sIssuedToComputer,@{Name="Issued"; Expression={$_.ConvertToDateTime($_.IssueDate)}},LicenseID | Sort-Object -Descending issued

 write-host ""
$LicenseID = Read-Host Enter License ID for most current license to NOT revoke
cls
write-host ""

$Revoke = (gwmi -ComputerName tslice WIN32_TSISSUEDLICENSE | where { $_.keypackid -eq 11 } `
 | where { $_.sIssuedToComputer -eq $ISSUEDTO} | where { $_.LicenseID -ne $LicenseID})

 $Exclude = (gwmi -ComputerName tslice WIN32_TSISSUEDLICENSE | where { $_.keypackid -eq 11 } `
 | where { $_.sIssuedToComputer -eq $ISSUEDTO} | where { $_.LicenseID -eq $LicenseID})

Write-Host -ForegroundColor RED "Excluding:"
$Exclude | select sIssuedToComputer,@{Name="Issued"; Expression={$_.ConvertToDateTime($_.IssueDate)}},LicenseID | Sort-Object -Descending issued
write-host ""

Write-Host To Be Revoked: ----------------------------------------------------------- -ForegroundColor RED
$Revoke | select sIssuedToComputer,@{Name="Issued"; Expression={$_.ConvertToDateTime($_.IssueDate)}},LicenseID | Sort-Object -Descending issued

write-host ""
Write-Host Are you sure you want to Revoke these CALs, enter 'YES' to confirm
$CONFIRM = Read-Host 

IF($CONFIRM -eq 'YES')
{
Write-Host Revoking...
$Revoke.Revoke()
}

ELSE
{
Write-Host Exiting...
Exit
}