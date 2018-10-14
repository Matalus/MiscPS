Remove-Variable * -ErrorAction SilentlyContinue
$user = Read-Host -Prompt "Enter Username"
$pass = Read-Host -AsSecureString -Prompt "Enter Password" | ConvertFrom-SecureString

$cred = New-Object -TypeName PSObject
$cred | Add-Member -NotePropertyName "username" -NotePropertyValue $user
$cred | Add-Member -NotePropertyName "passwordhash" -NotePropertyValue $pass
$securecred += $cred

$securecred | Export-Csv U:\securecreds.csv -Append