
$ErrorActionPreference = 'SilentlyContinue'

$Servers = Get-ADComputer -Filter * -SearchBase "OU=IT,DC=Contoso,DC=Com" -SearchScope Subtree -Properties Name | sort Name

$WmiObject = @{
   Class  = "Win32_Service"
   Filter = "startmode = 'auto' AND state != 'running'"
}

foreach ($Server in $Servers){

   foreach ($Svc in Get-WmiObject @WmiObject -ComputerName $Server){

      Start-Service $Svc | Out-Null

      Write-Host "Starting the $Svc.DisplayName service on $Server"

   }

Write-Host "Complete"

}


}