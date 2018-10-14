Import-Module ActiveDirectory -ErrorAction SilentlyContinue

CLS
"Exports AD 'Member of' Group Memberships to CSV"
""

$user = Read-Host -Prompt "Enter User Name"

Get-ADPrincipalGroupMembership -Identity $user | Export-Csv s:\$user.csv

"file has been exported to S:\$user.csv"