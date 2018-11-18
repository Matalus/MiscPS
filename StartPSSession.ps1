$options = New-PSSessionOption -SkipCACheck

$RemoteHost = Read-Host -prompt "Enter Remote Host"

if(!$cred){
    $cred = Get-Credential -Message "Enter Remote Credentials"
}
$sessionparams = @{
    Name = $RemoteHost 
    ComputerName = $RemoteHost
    Port = 5986
    Credential = $cred
    SessionOption = $options 
    UseSSL = $true
}

"Creating Session: $($sessionparams.Name)"
$session = New-PSSession @sessionparams
Enter-PSSession -Session $session