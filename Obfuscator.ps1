$user = $null
$pass = $null
$cred = $null
$user = Read-Host -Prompt "Enter Username"
$pass = Read-Host -AsSecureString -Prompt "Enter Password" | ConvertFrom-SecureString

$cred = New-Object -TypeName PSObject
$cred | Add-Member -NotePropertyName "username" -NotePropertyValue $user
$cred | Add-Member -NotePropertyName "passwordhash" -NotePropertyValue $pass
$securecred = $null
$securecred += $cred

$securecred | Export-Csv U:\securecreds.csv -Append



$CSV = Import-Csv U:\securecreds.csv
$neededcred = $CSV | ?{$_.username -eq "adage"}
$encrypt =  $neededcred.passwordhash | ConvertTo-SecureString


$Credentials = New-Object System.Management.Automation.PSCredential($user, $encrypt) 

$plainpass = $Credentials.GetNetworkCredential().password

$plainpass