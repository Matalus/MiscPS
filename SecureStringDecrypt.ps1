Remove-Variable * -ErrorAction SilentlyContinue

$user = Read-Host -Prompt "Enter username to retrieve"

$CSV = Import-Csv U:\securecreds.csv
$CSV | ft -AutoSize
$neededcred = $CSV | ?{$_.username -eq $user}
"selected $user" 
$neededcred
$encrypt =  $neededcred.passwordhash | ConvertTo-SecureString


$Credentials = New-Object System.Management.Automation.PSCredential($user, $encrypt) 

$plainpass = $Credentials.GetNetworkCredential().password



C:\product\11.1.0\client_1\sqlplus.exe $user/$plainpass@adagedev @u:\logging_test.sql
Remove-Variable * -ErrorAction SilentlyContinue