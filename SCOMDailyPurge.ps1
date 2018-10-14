$OpenAlerts = Get-SCOMAlert | ?{$_.ResolutionState -eq 0 -and $_.Severity -eq "Error"}
$OpenAlerts | Set-SCOMAlert -ResolutionState 255