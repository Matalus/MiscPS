Add-PSSnapin M*
Send-MailMessage -SmtpServer OA.corpdomain.com -Body "On Call - Change Over to After Hours On Call" -To PagingSESPOC@corpdomain.com -From WinService@corpdomain.com -Subject "On Call Changeover"
$CSV = Import-Csv \\vault\tech3\Scripts\Matt\OnCall.csv
Remove-DistributionGroupMember -Identity OnCallServerAdmin -Member PagingSESPOC -Confirm:$false
foreach($contact in $CSV)
{Add-DistributionGroupMember -Identity OnCallServerAdmin -Member $contact.Alias}
$members = Get-DistributionGroupMember -Identity OnCallServerAdmin | ?{$_.name -like '*Paging*'} | select name
Send-MailMessage -SmtpServer OA.corpdomain.com -Body "On Call - Change Over to After Hours On Call{ $members" -To OnCallServerAdmin@corpdomain.com -From WinService@corpdomain.com -Subject "On Call Changeover"
