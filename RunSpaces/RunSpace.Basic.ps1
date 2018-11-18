#Basic RunSpace Tutorial

#Setup RunSpace Pool
$pool = [runspacefactory]::CreateRunspacePool(
   1, #min processors
   $env:NUMBER_OF_PROCESSORS + 1 #max processors
)
$pool.ApartmentState = "MTA" #MTA = multi-thread STA = single
$pool.Open()

$RunSpaces = @() #array for storing runspace data

$ScriptBlock = {
   Param( #set params
      [string]$class 
   )
   Get-WmiObject $class | Select-Object -first 1 #simple command for demonstration
}

$classes = @( #array of sample data first 50 WMI classes
   "Win32_DeviceChangeEvent",
   "Win32_SystemConfigurationChangeEvent",
   "Win32_VolumeChangeEvent",
   "Win32_SystemTrace",
   "Win32_ProcessTrace",
   "Win32_ProcessStartTrace",
   "Win32_ProcessStopTrace",
   "Win32_ThreadTrace",
   "Win32_ThreadStartTrace",
   "Win32_ThreadStopTrace",
   "Win32_ModuleTrace",
   "Win32_ModuleLoadTrace",
   "Win32_PowerManagementEvent",
   "Win32_ComputerSystemEvent",
   "Win32_ComputerShutdownEvent",
   "Win32_IP4RouteTableEvent",
   "Win32_LogicalDisk",
   "Win32_MappedLogicalDisk",
   "Win32_DiskPartition",
   "Win32_Volume",
   "Win32_CacheMemory",
   "Win32_SMBIOSMemory",
   "Win32_MemoryArray",
   "Win32_MemoryDevice",
   "Win32_DiskDrive",
   "Win32_TapeDrive",
   "Win32_CDROMDrive",
   "Win32_PnPEntity",
   "Win32_1394Controller",
   "Win32_VideoController",
   "Win32_SCSIController",
   "Win32_InfraredDevice",
   "Win32_PCMCIAController",
   "Win32_USBController",
   "Win32_SerialPort",
   "Win32_ParallelPort",
   "Win32_IDEController",
   "Win32_Processor",
   "Win32_Printer",
   "Win32_Battery",
   "Win32_PortableBattery",
   "Win32_TemperatureProbe",
   "Win32_VoltageProbe",
   "Win32_CurrentProbe",
   "Win32_Bus",
   "Win32_Keyboard",
   "Win32_DesktopMonitor",
   "Win32_PointingDevice",
   "Win32_USBHub",
   "Win32_NetworkAdapter"
)
$count = 0 #counter for loop
ForEach($class in $classes){ #loop through WMI classes and create runspace for each
   $count++ #increment counter
   $runspace = [PowerShell]::Create() #create the runspace
   "$count : Created RunSpace for class : $class"
   $null = $runspace.AddScript($ScriptBlock) #set command
   $null = $runspace.AddArgument($class) #set params
   $runspace.RunSpacePool = $pool #attach to pool
   $RunSpaces += [PSCustomObject]@{ #psobject for tracking
      Count = $count
      Pipe = $runspace
      Status = $runspace.BeginInvoke()
   }
}

$Results = @() #empty array for results

while ($null -ne $RunSpaces.status){ #wait for Status to complete
   $completed = $RunSpaces | Where-Object{ #get completed runspaces
      $_.Status.IsCompleted -eq $true
   }
   foreach($runspace in $completed){ #write completed runspaces to results array
      $Results += [PSCustomObject]@{ #psobject for results array and append to results @()
         Count = $runspace.Count
         Return = $runspace.Pipe.EndInvoke($runspace.status)
         Command = $runspace.Pipe.Commands.Commands
         Completed = $runspace.Status.IsCompleted
      }
      $runspace.status = $null #clear runspace status
   }
}

$pool.Close() #clean up
$pool.Dispose()
