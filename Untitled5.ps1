$array = Get-Content '\\aztask\c$\scripts\owcheck.txt'
ForEach($server in $array)
{
Get-WmiObject -ComputerName $server Win32_ComputerSystem | select * | Export-Csv \\vault\tech3\OW_CS.csv -Append
}