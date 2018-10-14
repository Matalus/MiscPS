$ID = $ARGS[0]
"TESTING"
$ID
$ID >> \\vault\tech3\Scripts\Matt\AlertID.txt
Add-PSSnapin M*
FOR(;;)
    {
#$ID = "13c900b4-cd49-46a8-9eaa-08078075a715"
$alert = $null
$alert = Get-SCOMAlert -Id $ID
$alert
$State = $alert.ResolutionState
    IF($State -eq 0)
        {
        $d = (Get-Date) 
        "$d True"
        $alert.Update("")
        }
        ELSE
        {
        
        $d = (Get-Date) 
        "$d False" 
        "Closed" >> >> \\vault\tech3\Scripts\Matt\AlertID.txt
        BREAK
        }
    Start-Sleep -Seconds 300
    }