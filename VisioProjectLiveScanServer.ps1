Import-Module ActiveDirectory

FOR(;;)
{

$CSV = Import-Csv '\\appdata\crossdep$\SoftwareQuery\redolist.csv'

$CSV = $CSV | sort name
$count = 0


ForEach($Computer in $CSV)
    {
    
    $Computer = $Computer.name
    $Remaining = $CSV.Count
    Write-Progress -Activity "Objects Remaining" -Status "Scanning $count of $Remaining" -CurrentOperation $Computer -PercentComplete (($count/$Remaining) * 100)
    "----------------------------------------------------------"
    "$count Attempting to connect to $Computer"
    $Test = Test-Connection -Count 1 -ComputerName $COMPUTER -ErrorAction SilentlyContinue
        IF($Test -ne $null)
            {
            "Connected:"
            $count++
            $WMI = Get-WmiObject -ComputerName $Computer Win32_Product | Where-Object { $_.name -like '*Visio*' -or $_.name -like '*Project*'}
            $WMI
            $OUTPUT = $null
            $USER = Get-WmiObject -ComputerName $Computer win32_process | foreach{$_.getowner().user} | ?{ $_ -notmatch "Network Service|Local Service|System|Ctx_StreamingSvc"} | select -Unique
            $USER = 
            "Current User = $USER"
            foreach($RESULT in $WMI)
                {
                    $Name = $Result.name
                    $Name
                    $Version = $RESULT.Version
                    $Version
                    $GUID = $RESULT.IdentifyingNumber
                    $GUID
                    $OBJ = New-Object PSObject
                    $OBJ | add-member -membertype noteproperty -Name "Username" -Value $USER
                    $OBJ | add-member -membertype noteproperty -Name "ComputerName" -Value $COMPUTER
                    $OBJ | add-member -membertype noteproperty -Name "Software" -Value $Name
                    $OBJ | add-member -membertype noteproperty -Name "Version" -Value $Version
                    $OBJ | add-member -membertype noteproperty -Name "GUID"-Value $GUID
                    [array]$OUTPUT += $OBJ
                 }
                 $OUTPUT
                    "Scan Complete - Removing $Computer from list"
                    $CSV = $CSV | ?{ $_.name -ne $Computer}
                    $CSV | Export-Csv '\\appdata\crossdep$\SoftwareQuery\redolist.csv' -NoTypeInformation
                    IF($WMI -ne $null)
                        {
                            "Results Found - Check \\appdata\crossdep\SoftwareQuery\visio-project-livescan-Servers.csv"
                            $OUTPUT | Export-Csv \\appdata\crossdep\SoftwareQuery\visio-project-livescan-wks3.csv -Append -NoTypeInformation
                        }
                    ELSE
                        { 
                        "Nothing Found"
                        $Computer | Export-Csv \\appdata\crossdep\SoftwareQuery\livescancounter.csv -Append -NoTypeInformation
                        }
            
            }     
            ELSE
            {"Connection Failed"}
    }
}
             
        



