$CSV = Get-Content u:\deletelist.csv

$objUser = New-Object System.Security.Principal.NTAccount("shamrockfoods", "amis5235")
$Right = "FullControl"
$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit
$rule = new-object System.Security.AccessControl.FileSystemAccessRule([System.Security.Principal.NTAccount]'SHAMROCKFOODS\Domain Admins',"FullControl","Allow","ContainerInherit")

$count = 0
CLS
foreach($DIR in $CSV)
{
#[string]$DIR = """$DIR
$Count++

Write-Host $count Attempting to Delete $DIR
$QUERY = Get-ChildItem -Path $DIR -Recurse -filter *attachmate*
Write-Host Getting ACL
    foreach($File in $QUERY)
    {
    $ACL = $QUERY | Get-Acl
    $ACL
    Write-Host Modifying ACL rules
    $ACL.SetOwner(([System.Security.Principal.NTAccount]'SHAMROCKFOODS\Domain Admins'))
    $ACL.SetAccessRule($rule)

    Write-Host Applying ACL Rules to Directory
    
    $QUERY | Set-Acl -AclObject $ACL 
    }
        Write-Host Attempting to Delete

$QUERY | Remove-Item -Force -Recurse
$QUERY = $null
$QUERY = Get-ChildItem -Path $DIR -Recurse -Filter *attachmate*
$QUERY
$ACL = $QUERY | Get-Acl
$ACL
    IF($QUERY -eq $null)
        {Write-Host $DIR "| - has been removed"
        Test-Path $DIR
        }
        ELSE
        {
        Write-Host $DIR - Still Exists
        Test-Path $DIR
        }
Write-Host " "
}
$count = 0
CLS