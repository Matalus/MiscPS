Import-Module PSTerminalServices

ForEach($server in $xdaz)
{
$session = Get-TSSession -ComputerName $server | ?{$_.UserName -eq "AWHSTEST" -and $_.WindowStationName -like "*ICA-TCP*"}
$session
IF($session -ne $null){"$server session found disconnecting..."
$session | Stop-TSSession -Force
}
$session = $null
$session = Get-TSSession -ComputerName $server | ?{$_.UserName -eq "AWHSTEST" -and $_.WindowStationName -like "*ICA-TCP*"}
$session
}