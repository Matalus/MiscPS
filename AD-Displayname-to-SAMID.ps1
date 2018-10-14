forEach($user in Get-Content u:\test.txt) 
{Get-ADUser -Filter * -Properties Displayname | Where-Object { $_.Displayname -eq $user } | ft -HideTableHeaders -AutoSize SamAccountName,Displayname >> U:\samid.csv }
Invoke-Item u:\samid.csv