Add-PSSnapin M*
$ONCALL = Get-DistributionGroupMember -Identity OnCallServerAdmin | ?{$_.name -like '*Paging*'-and $_.name -ne "PagingSysEngineers" -and $_.name -ne "PagingSESPOC" }
$ONCALL | Export-Csv \\vault\tech3\Scripts\Matt\OnCall.csv
Send-MailMessage -SmtpServer OA.shamrockfoods.com -Body "On Call - Change Over to Daytime SPOC" -To OnCallServerAdmin@shamrockfoods.com -From WinService@shamrockfoods.com -Subject "On Call Changeover"
foreach($contact in $ONCALL)
    {Remove-DistributionGroupMember -Identity OnCallServerAdmin -Member $contact -Confirm:$false}

    Add-DistributionGroupMember -Identity OnCallServerAdmin -Member PagingSESPOC
    $members = Get-DistributionGroupMember -Identity OnCallServerAdmin | ?{$_.name -like '*Paging*'} | select name
    Send-MailMessage -SmtpServer OA.shamrockfoods.com -Body "On Call - Change Over to Daytime SPOC{ $members" -To PagingSESPOC@shamrockfoods.com -From WinService@shamrockfoods.com -Subject "On Call Changeover"



