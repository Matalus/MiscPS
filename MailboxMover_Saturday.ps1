Write-Output test >> \\vault\tech3\Scripts\Matt\testrun.txt

$d = Get-Date -Format MM.dd.yyyy-HH.mm

Stop-Transcript -ErrorAction SilentlyContinue
Start-Transcript "\\vault\tech3\Scripts\Matt\logs\MailboxMoveLog$d.log" -Append

$CSV = Import-Csv \\vault\tech3\Scripts\Matt\movecsv.csv

$Remaining = $CSV

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin -ErrorAction SilentlyContinue
$count = 0
$failcount = 0
foreach($Mailbox in $CSV)
    {
    $TEST = Test-Path -Path '\\vault\tech3\Scripts\Matt\stop.txt'

        IF($TEST -eq 'True')
        {Write-Host "STOP File Found Exiting..."
        Remove-Item -Path \\vault\tech3\Scripts\Matt\stop.txt
        Break
        }
        ELSE
        {
        #do nothing
        }







    $STOP = (Get-Date).hour
        IF($STOP -In 4..18)
            {
            Write-output (Get-Date) "Outside Approved Time Window Exiting..." >> \\vault\tech3\Scripts\Matt\exit.txt
            Write-output (Get-Date) "Outside Approved Time Window Exiting..."
            BREAK
            }
            ELSE
            {
            $SG = $Mailbox.Database
            $user = $Mailbox.DisplayName
   
            Write-Host ""
            Write-Host (Get-Date) Moving $user
            $Source = ([string](Get-MailboxStatistics -Identity $user).Database)
            Write-Host From: $Source
             Write-Host "To:  "  azmail\Storage Group $SG\Mailbox Database $SG

                IF($Source -eq "azmail\Storage Group $SG\Mailbox Database $SG")
                    {
                    Write-Host ""
                    Write-Host -ForegroundColor Magenta "Mailbox has already been moved - Skipping"
                    Write-Host ""
                    Start-Sleep -Seconds 1
                    Write-Host "Removing $user from CSV..."
                    $REMAINING = $REMAINING | Where-Object { $_.Displayname -ne $Mailbox.DisplayName}
                    $REMAINING | Export-Csv \\vault\tech3\Scripts\Matt\movecsv.csv -Force
                    Write-Host "CSV Updated..."
                    }
                    ELSE
                        {
                        Move-Mailbox -Identity $user -PreserveMailboxSizeLimit -BadItemLimit 50 -TargetDatabase "azmail\Storage Group $SG\Mailbox Database $SG" -Confirm:$False -MaxThreads 8 | Out-Null
                        Start-Sleep -Seconds 2
                        Write-Host ""
                        Write-Host "Verifiying Move..."
                        $MailboxStats = (Get-MailboxStatistics -Identity $user)
                        [string]$VERIFY = $MailboxStats.Database
            
                            IF($VERIFY -eq "azmail\Storage Group $SG\Mailbox Database $SG")
                                {
                                $count++
                                Write-Host -ForegroundColor Cyan $count "Move Successful!!!"

                                Write-Host ""
                                Start-Sleep -Seconds 1
                                Write-Host   "Removing $user from CSV"
                                $REMAINING = $REMAINING | Where-Object { $_.Displayname -ne $Mailbox.DisplayName}
                                $REMAINING | Export-Csv \\vault\tech3\Scripts\Matt\movecsv.csv -Force
                                Write-Host  "CSV Updated.."

                                $Report = New-Object psobject
                                $Report | Add-Member -NotePropertyName user -NotePropertyValue $user
                                $Report | Add-Member -NotePropertyName "Source SG" -NotePropertyValue $Source
                                $Report | Add-Member -NotePropertyName "Destination SG" -NotePropertyValue $MailboxStats.Database
                                $Report | Add-Member -NotePropertyName Items -NotePropertyValue $MailboxStats.ItemCount
                                $Report | Add-Member -NotePropertyName "Size(MB)" -NotePropertyValue $MailboxStats.TotalItemSize.Value.ToMB()
                                $Report | Export-Csv -Append -Path \\vault\tech3\Scripts\Matt\logs\Exchange_Moves\MoveLog$d.csv
                                }
                                ELSE
                                    {
                                    $failcount++
                                    Write-Host  -ForegroundColor Red $failcount "Move Failed - Entry Written to log"
                                    Write-Output "$failcount Move FAILED for $user  - Please Investigate" | Out-File "\\vault\Tech3\Scripts\Matt\logs\FailedMoves.log" -Append
                                    }
                        }


    Write-Host "-----------------------------------------------------------"
    
    
    
    }
    }

    #Mail Variables
$To="istech3@shamrockfoods.com"
#$To="Matt_Hamende@shamrockfoods.com"
$SMTP="OA.SHAMROCKFOODS.COM"
$FROM="winservice@shamrockfoods.com"
$SUBJECT="Mailbox Move Report"
$BODY = ""


$CSV = Import-Csv \\vault\tech3\Scripts\Matt\logs\Exchange_Moves\MoveLog$d.csv
#$CSV = Import-Csv "\\vault\tech3\Scripts\Matt\logs\Exchange_Moves\MoveLog03.16.2014-19.00.csv"
    
    $MBMOVED = ($CSV."Size(MB)" | Measure-Object -Sum).Sum
    $TotalItems = ($CSV.Items | Measure-Object -Sum).Sum

    $Remainingcount = $REMAINING.Count
    
    
    $BODY += “<font face=Calibri color=green size=5><h2>Mailbox Move Report</h2></font>"
    $BODY += "<font face=Calibri color=black size=3>"
    $BODY += "Total Mailboxes Moved &nbsp $count<BR>"
    $BODY += "Total Failed Moves &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp $failcount<BR>"
    $BODY += "Total Moved in MB &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp $MBMOVED <BR>"
    $BODY += "Total Items Moved &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp $TotalItems<BR><BR>"
    $BODY += "<B>Mailboxes Remaining &nbsp;&nbsp;&nbsp $Remainingcount</B><BR><BR>"
    $BODY += "</font>"

$html = “<style>”
$html = $html + “BODY{background-color:white; font-family:Calibri;}”
$html = $html + “TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}”
$html = $html + “TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Slategray; font-size:14pt;}”
$html = $html + “TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Gainsboro; font-size:12pt;}”
$html = $html + “</style>”



    $BODY += $CSV | select * -Unique | ConvertTo-Html -Head $HTML

    Send-MailMessage -To $TO -From $FROM -Subject $SUBJECT -Body $BODY -SmtpServer $SMTP -BodyAsHtml

    Write-Host "Total Mailboxes Moved" $count
    Write-Host "Total Failed Moves   " $failcount



    Stop-Transcript