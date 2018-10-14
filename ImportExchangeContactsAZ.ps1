#Creates Variable object and imports CSV as an array
Start-Transcript \\vault\tech3\Scripts\Matt\logs\ImportExchangeContactsAZ.log

#Imports Exchange Management Shell Snap-in
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin

$CSV = Import-Csv "\\userdata\isshare$\helpdesk\Projects and Tasks\2014\Rob Ahrensdorf\CSV - Shamrock Arizona Customer Email Addresses Sept 2013.csv"

#Sets Error Preference to Suppress Errors
#$ErrorActionPreference="SilentlyContinue"

#Mail Execution Loop runs commands in brackets for each item in the array
foreach( $Contact in $CSV)
{ 
#Deletes contact if pre-existing
Remove-MailContact -Identity $Contact.ExternalEmailAddress -Confirm:$false
#Creates Contact
New-MailContact -ExternalEmailAddress $Contact.ExternalEmailAddress -FirstName $Contact.FirstName -LastName $Contact.LastName -Name $Contact.ExternalEmailAddress
#Adds to Designated Distro Group
Add-DistributionGroupMember -Identity "AZ Street Sales" -Member $Contact.ExternalEmailAddress
}
Stop-Transcript