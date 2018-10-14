Import-Module ActiveDirectory

For(;;)
{

$CSV = Import-Csv \\vault\tech3\Scripts\Matt\Workstations.csv

$CSV = $CSV | sort name

$count = 0


ForEach($Computer in $CSV)
    {
    $count++
    $Computer = $Computer.name
    #$Computer = "xdaz05"
    $Remaining = $CSV.Count
    Write-Progress -Activity "Objects Remaining" -Status "Scanning $count of $Remaining" -CurrentOperation $Computer -PercentComplete (($count/$Remaining) * 100)
    "----------------------------------------------------------"
    "$count Attempting to connect to $Computer"
    $Test = Test-Connection -Count 1 -ComputerName $COMPUTER -ErrorAction SilentlyContinue
        IF($Test -ne $null)
            {
            "Connected:"
            $WMI = Get-WmiObject -ComputerName $Computer Win32_Product | Where-Object { $_.name -like '*Visio*' -or $_.name -like '*Project*'}
            $WMI
            $OUTPUT = $null
            $USER = Get-WmiObject win32_USERPROFILE -ComputerName $Computer | ?{$_.sid -like "S-1-5-21-692696351-4240734353-4249266749*"} | sort lastusetime -Descending | select -First 1
            $profilename = ($USER.LocalPath.Split("\")[2]).split(".")[0]
            $Commonname = (Get-ADUser -Identity $profilename).name
            "Current User = $Commonname $profilename"

            foreach($RESULT in $WMI)
                {
                    $Name = $Result.name
                    $Name
                    $Version = $RESULT.Version
                    $Version
                    $GUID = $RESULT.IdentifyingNumber
                    $GUID
                    $OBJ = New-Object PSObject
                    $OBJ | add-member -membertype noteproperty -Name "Common Name" -Value $commonname
                    $OBJ | add-member -membertype noteproperty -Name "Username" -Value $profilename
                    $OBJ | add-member -membertype noteproperty -Name "ComputerName" -Value $COMPUTER
                    $OBJ | add-member -membertype noteproperty -Name "Software" -Value $Name
                    $OBJ | add-member -membertype noteproperty -Name "Version" -Value $Version
                    $OBJ | add-member -membertype noteproperty -Name "GUID"-Value $GUID
                    [array]$OUTPUT += $OBJ
                 }
                 $OUTPUT
                    "Scan Complete - Removing $Computer from list"
                    $CSV = $CSV | ?{ $_.name -ne $Computer}
                    $CSV | Export-Csv \\vault\Tech3\Scripts\Matt\Workstations.csv -NoTypeInformation
                    IF($WMI -ne $null)
                        {
                            "Results Found - Check \\appdata\crossdep\SoftwareQuery\visio-project-livescan-workstations.csv"
                            $OUTPUT | Export-Csv \\appdata\crossdep\SoftwareQuery\visio-project-livescan-workstations2.csv -Append -NoTypeInformation
                        }
                    ELSE
                        { 
                        "Nothing Found"
                        $Computer | Export-Csv \\appdata\crossdep\SoftwareQuery\livescancounter2.csv -Append -NoTypeInformation
                        }
            
            }     
            ELSE
            {"Connection Failed"}
    }
}
             
        



