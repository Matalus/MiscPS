gwmi -ComputerName tslice WIN32_TSISSUEDLICENSE | where { $_.keypackid -eq 11 -and $_.LicenseStatus -ne 4} `
 | Group-Object sIssuedtoComputer | Where-Object { $_.count -gt 1} | Sort-Object count -Descending | ft -AutoSize name,count | more

