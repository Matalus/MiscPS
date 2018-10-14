Import-Module DataONTAP

Connect-NaController 3170azb
CLS

[timespan] $TS = (Get-Date) - (Get-Date).AddMinutes(-30)
"SnapshoPurge.ps1 - Created by Matt Hamende SFC 2014 - Leveraging NetApp DataONTAP PowerShell Module"
""
"This script will check the snapmirror lag time on all volumes that contain exchange storage groups"
"This allows us to safely delete snapshots knowing that we have a DR backup copy available on VAULT"
""
"A Time Buffer will be Calculated based on twice the highest snapmirror lag interval"
"No Snapshots that were created inside this buffer will be deleted"
""
Write-Host "It is Strongly Recommended to run this script in read-only mode to determine scope prior to deleting any snapshots" -ForegroundColor Red -BackgroundColor Yellow
""
"READ-ONLY MODE:"
$READONLY = Read-Host "Run in Read Only Mode? - Enter Y or N"
CLS

$SNAPLAG = Get-NaSnapmirror | where { $_.SourceLocation -like '*azmail*' -and $_.SourceLocation -notlike '*public*' -and $_.LagTimeTS -ge $TS} 
"Running Snaplag Query"

IF($SNAPLAG -ne $null)
    {
    Write-Host "WARNING: Some Snapmirrors have a lag time over 30 minutes" -ForegroundColor Red
    ""
    $SNAPLAG | ft SourceLocation,DestinationLocation,LagTimeTS
    }
    ELSE
    {
    ""
    Write-Host "No Snapmirrors are more than 30 minutes lagged" -ForegroundColor Green
    ""
    Get-NaSnapmirror | where { $_.SourceLocation -like '*azmail*' -and $_.SourceLocation -notlike '*public*'} | ft SourceLocation,DestinationLocation,LagTimeTS
    }


$LAG = ($SNAPLAG.LagTimeTS.TotalHours)
$LAGHOURS = [math]::Round(($LAG | Measure-Object -Maximum).Maximum)

$CONTINUE = Read-Host "Continue? : y/n"
IF($CONTINUE -eq 'n')
{
Break
}

$VOLS = Get-NaVol | where { $_.name -like '*azmailsg*'} | Where-Object { $_.name -notlike '*quorum*' -and $_.name -notlike '*sdw_cl*'}

$Count = ($VOLS).count
$i = 0
$d = (Get-Date).Addhours(-$LAGHOURS)
""
"Adding Buffer of $LAGHOURS Hours - Ignoring any snapshots earlier than this"


ForEach($SG in $VOLS)
    {
    
    $SG.name
    ">SNAPS TO BE DELETED:"
    $DELETE = $SG | Get-NaSnapshot | where { $_.dependency -notlike '*snapmirror*' -and $_.AccessTimeDT -lt $d -and $_.name -notlike '*recent' } 
    $DELETE | ft name,targetname,AccessTimeDT,Dependency,@{Expression={ [math]::Round($_.Total /1MB) };Label="Size(MB)"} -AutoSize
    $i++
    Write-Progress -Activity "Deleting Snapshots..." -Status "Deleting Snapshots on Volume $i of $count" -CurrentOperation $SG -PercentComplete (($i/$count) * 100)
    
    IF($READONLY -eq 'n')
        {
        ">DELETING:"

        $DELETE | Remove-NaSnapshot -Confirm:$false
        
        }
        ELSE
        {
        Write-Host "READ-ONLY MODE is enabled" -ForegroundColor Red
        }
    ">Remaining SNAPS:"
    $SG | Get-NaSnapshot | ft name,targetname,AccessTimeDT,Dependency,@{Expression={ [math]::Round($_.Total /1MB) };Label="Size(MB)"} -AutoSize
    Write-Host __________________________________________________________________________________________________
    }

    ""
    "Current Status of Aggregate"
    ""
    $AGGR = Get-NaAggr -Name fcaggr0 
    $AGGR | ft name,SizePercentageUsed,@{Expression={[math]::Round($_.SizeAvailable /1GB)};Label="Available(GB)"},`
    @{Expression={[math]::Round($_.SizeUsed /1GB)};Label="Used(GB)"},`
    @{Expression={[math]::Round($_.SizeTotal /1GB)};Label="Total(GB)"} -AutoSize
    
    $Total = ([math]::Round($AGGR.SizeTotal /1GB))
    $92 = ($Total /100) * 92
    $NEEDED = $Total - $92
    
    ""
   Write-host "Need $NEEDED GB Available Space to reach Yellow Threshold" -ForegroundColor Green
   
  

