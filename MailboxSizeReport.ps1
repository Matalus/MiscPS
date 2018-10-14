$ErrorActionPreference = "SilentlyContinue"

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin

#Get-MailboxDatabase | Where-Object { $_.name -like '*Mailbox Database 6*'} | Get-MailboxStatistics | fl

Get-MailboxDatabase | Get-MailboxStatistics | sort DisplayName | select DisplayName,StorageGroupName,@{Expression={ ($_.LegacyDN.Replace("/O=SHAMROCK FOODS/OU=EXCHANGE ADMINISTRATIVE GROUP (FYDIBOHF23SPDLT)/CN=RECIPIENTS/CN=",""))};Label="SAM"},ItemCount,@{Expression={ $_.TotalItemSize.Value.ToMB()};Label="Size"},LastLogonTime,LastLogOffTime,LastLoggedOnUserAccount | Export-Csv \\vault\tech3\MailboxSizeReport.csv

Invoke-Item \\vault\tech3\MailboxSizeReport.csv