$computer = read-host "Enter computer name:"
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$Cred = Get-Credential
$computers = $computer
$Domain= "Whatever"

$rtn = Test-Connection -CN $computer -Count 1 -BufferSize 8 -Quiet

$invokeParams = @{
   ComputerName = $computers
   ArgumentList =  $RegPath, $Domain, $DefaultUsername, $DefaultPassword
   Credential = $Cred
   ScriptBlock = {
      [PSCustomObject]@{
         AutoAdminLogon       = Set-ItemProperty $args[0] "AutoAdminLogon" -Value "1" -type String
         DefaultDomainName    = Set-ItemProperty $args[0] "DefaultDomainName" -Value $args[1] -type String
         AltDefaultUserName   = Set-ItemProperty $args[0] "AltDefaultUserName" -Value $args[2] -type String
      }
   } 
}

if($rtn){
   $Results = Invoke-Command @invokeParams
}
else { 
   Write-host -ForegroundColor red $computer "Computer is offline" 
}
