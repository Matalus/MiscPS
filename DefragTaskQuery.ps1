$list = Get-Content \\vault\tech3\Scripts\Matt\Server2012fix\2012servers.txt
$result = $null
ForEach($server in $list)

    {
    $SCHSERVICE = New-Object -ComObject Schedule.service
    $SCHSERVICE.Connect($server)
    $ROOT = $SCHSERVICE.GetFolder("\Microsoft\Windows\Defrag")
    $TASK = $ROOT.GetTasks(0)
    $TASK | ft @{Expression={$($SCHSERVICE.TargetServer)};Label="Server"},name,state,enabled,lastruntime,nextruntime
    $obj = New-Object psobject
    $obj | Add-Member -NotePropertyName Server -NotePropertyValue $server
    $obj | Add-Member -NotePropertyName name -NotePropertyValue $task.item(1).name
    $obj | Add-Member -NotePropertyName state -NotePropertyValue $TASK.item(1).state
    $obj | Add-Member -NotePropertyName enabled -NotePropertyValue $TASK.item(1).enabled
    $obj | Add-Member -NotePropertyName lastruntime -NotePropertyValue $TASK.item(1).lastruntime
    $obj | Add-Member -NotePropertyName nextruntime -NotePropertyValue $TASK.item(1).nextruntime
    [array]$result += $obj
    }
    $result | ft