Get-SCOMAlertResolutionState

$BADSTATE = Get-SCOMMonitoringObject | where { $_.HealthState -ne 'success' -and $_.HealthState -ne 'uninitialized'}

$Count = $BADSTATE.count

CLS

"$Count Bad Items"

$i = 0
ForEach($item in $BADSTATE)
    {
    $i++
    $item.ResetMonitoringState()
    write-progress -activity "Reset Status" -Status "Job $i of $count Complete" -Percentcomplete ($i/$count)
    }

$BADSTATE = Get-SCOMMonitoringObject | where { $_.HealthState -ne 'success' -and $_.HealthState -ne 'uninitialized'}
$Count = $BADSTATE.Count

"$Count Bad Items"

