$RunDir = split-path -parent $MyInvocation.MyCommand.Definition
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

"Password Hashed: $secure"

$securecred | Export-Csv $RunDir\securecreds.csv -Append



$CSV = Import-Csv $RunDir\securecreds.csv
$neededcred = $CSV | Where-Object{$_.username -eq $user}
$encrypt =  $neededcred.passwordhash | ConvertTo-SecureString


$Credentials = New-Object System.Management.Automation.PSCredential($user, $encrypt) 

$plainpass = $Credentials.GetNetworkCredential().password

$plainpass