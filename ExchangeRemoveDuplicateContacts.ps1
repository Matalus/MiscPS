$CSV = Import-Csv "\\userdata\isshare$\helpdesk\Projects and Tasks\2014\Rob Ahrensdorf\export.csv"

#Imports Exchange Management Shell Snap-in
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin


$count = 0
foreach( $Contact in $CSV)
{
    $QUERY = $null
    $QUERY = Get-MailContact -Identity $Contact.Email -ErrorAction SilentlyContinue
    IF($QUERY -ne $null)
        {
        #exists ignore
        }
        ELSE
        {
        $count++
        Write-Host $count $Contact.Email
        $Contact | Export-Csv -Append "\\userdata\isshare$\helpdesk\Projects and Tasks\2014\Rob Ahrensdorf\Duplicates_removed_Total_Broadline.csv"
        }
}