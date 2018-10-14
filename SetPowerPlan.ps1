#Sets Power Plan on Servers Remotely using Remote WMI
#Created by Matt Hamende 2014

#list of servers to run against
$list = Get-Content \\vault\tech3\Scripts\Matt\Server2012fix\2012servers.txt
#Enter plan name "Balanced", "High Performance", or "Power Saver"
$SetPlan = "High Performance"
#initiates Loop
ForEach($Server in $list)
    {
    $Server
    #Queries current Power Plan
    $HighPerf = Get-WmiObject -ComputerName $Server -Namespace root\cimv2\power -Class Win32_PowerPlan
    $HighPerf | ft pscomputername,elementname,isactive,instanceid
    #Sets Power Plan to desired plan
    ($HighPerf | ?{$_.elementname -eq $SetPlan}).Activate() 
    #follow up query to determine correct plan is set
    $Active = Get-WmiObject -ComputerName $Server -Namespace root\cimv2\power -Class Win32_PowerPlan | ?{$_.isactive -eq $true}
    $plan = $Active.elementname
    $pscompname = $Active.pscomputername
    "Power Plan is now set to $plan on Host $pscompname"
    
    }