$log = (Get-StorageGroup) | Where-Object{ $_.LogFolderPath -notlike '*public*' -and $_.LogFolderPath -notlike '*journal*'}
$log = ($log).LogFolderPath.pathname.Replace("M:\","\\azmail\m$\")
foreach($path in $log)
{
$delete = Get-ChildItem $path -Recurse | ?{$_.name -notmatch 'E...log' -and $_.name -notmatch 'tmp' -and $_.name -notlike '*.jrs' -and $_.name -match '\.log'}
$delete
$delete | Remove-Item -Force -Recurse
}