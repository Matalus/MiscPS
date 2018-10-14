Connect-NaController 3170azb -ErrorAction SilentlyContinue
"Querying Log Volumes"
$snap = Get-NaVol | ?{$_.name -like "azmaillogs*" -and $_.Aggregate -eq "fcaggr0"} | Get-NaSnapshot | ?{$_.Created -le (Get-Date).AddDays(-2)}
$snap.count
$snap | ft
$answer = $null
$answer = Read-Host -Prompt "Do you want to Delete these snapshots? - Enter Y or N"
IF($answer -eq "Y"){$snap | Remove-NaSnapshot -Confirm:$false}