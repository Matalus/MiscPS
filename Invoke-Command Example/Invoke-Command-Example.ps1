$computer = read-host "Enter computer name:"
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$Cred = Get-Credential
$computers = $computer
$Domain= "Whatever"

$rtn = Test-Connection -CN $computer -Count 1 -BufferSize 8 -Quiet

if($rtn){
   Invoke-Command -ComputerName $computers -Credential $Cred -ScriptBlock {
      Set-ItemProperty $args[0] "AutoAdminLogon" -Value "1" -type String
      Set-ItemProperty $args[0] "DefaultDomainName" -Value $args[1] -type String
      Set-ItemProperty $args[0] "AltDefaultUserName" -Value $args[2] -type String
   } -ArgumentList $RegPath, $Domain, $DefaultUsername, $DefaultPassword
}
else { 
   Write-host -ForegroundColor red $computer "Computer is offline" 
}
