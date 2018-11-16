$options = New-PSSessionOption -SkipCACheck
if(!$cred){
    $cred = Get-Credential -Message "Enter Remote Credentials" -UserName "Administrator"
}
$sessionparams = @{
   ComputerName = "ec2-18-191-80-42.us-east-2.compute.amazonaws.com"
   Port = 5986
   Credential = $cred
   SessionOption = $options
   UseSSL = $true
}

Enter-PSSession @sessionparams