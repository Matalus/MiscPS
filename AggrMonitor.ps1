for(;;)
{

$AGGR = Get-NaAggr -Name fcaggr0 
    $AGGR | ft name,SizePercentageUsed,@{Expression={[math]::Round($_.SizeAvailable /1GB, 2)};Label="Available(GB)"},`
    @{Expression={[math]::Round($_.SizeUsed /1GB, 2)};Label="Used(GB)"},`
    @{Expression={[math]::Round($_.SizeTotal /1GB, 2)};Label="Total(GB)"} -AutoSize

    Start-Sleep -Seconds 5
    CLS
    }
    