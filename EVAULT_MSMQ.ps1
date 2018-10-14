$SERVICESTATUS = (Get-Service -ComputerName EXEVAULT -Name MSMQ).Status
IF($SERVICESTATUS -eq "running")
{ "Running" }
ELSE
{ "Not Running" }