#This example demonstrates how to effectively build tables using an array of psobjects 

#Get Process Data for example data
$Procs = Get-Process | Select-Object -First 20

#Array to append objects to
$ProcArray = @()

#Loop through $Procs and append to psobject array
ForEach($Proc in $Procs){
   #You can add in data from different sources in the loop
   $Workstation = $ENV:COMPUTERNAME
   #Create Object and append to array
   $ProcArray += [pscustomobject]@{
      PID = $Proc.ID #PID
      Name = $Proc.Name #Process Name
      Owner = (Get-WmiObject Win32_Process -filter "ProcessID=$($Proc.ID)").GetOwner().User #the value of a psobject property can be code itself
      WorkStation = $Workstation
   }
}

$ProcArray | Format-Table -AutoSize

