$CSV = Import-Csv "\\userdata\isshare$\helpdesk\Projects and Tasks\2014\Rob Ahrensdorf\CSV Test - Shamrock New Mexico Customers Email Addresses Sept 2013.csv"

foreach( $Contact in $CSV)
{Write-Host $Contact| ft 
New-MailContact -ExternalEmailAddress $Contact.ExternalEmailAddress -FirstName $Contact.FirstName -LastName $Contact.LastName -Name $Contact.ExternalEmailAddress
Add-DistributionGroupMember -Identity "AZ Street Sales" -Member $Contact.ExternalEmailAddress
}
