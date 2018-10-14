#Disable-DefragTask-2012.ps1 - Written by - Matt Hamende
#Checks state of scheduled tasks for Server 2012 defrags and disables if enabled.
$Servers = @("dirac1","dirac2")
ForEach($Server in $Servers)
    {
    Invoke-Command -ComputerName $Server -ScriptBlock { $task = Get-ScheduledTask | ?{$_.taskname -like "*defrag*"};
    $task ;
    IF($task.state -ne 1){$task | Disable-Scheduledtask}}
    }