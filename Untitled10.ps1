$xdaz = Get-Content \\vault\tech3\Scripts\Matt\xen.txt

ForEach($server in $xdaz)
{
$session = Get-TSSession -ComputerName $server | ?{$_.UserName -eq "AWHSTEST" -and $_.WindowStationName -like "*ICA-TCP*"}
$session
IF($session -ne $null){"$server session found disconnecting..."
$session | Stop-TSSession -Force
}
$session = Get-TSSession -ComputerName $server | ?{$_.UserName -eq "AWHSTEST" -and $_.WindowStationName -like "*ICA-TCP*"}
$session
}