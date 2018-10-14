$keyname =@('SYSTEM\\CurrentControlSet\\Services\\PerfProc\\Performance',`
'SYSTEM\\CurrentControlSet\\Services\\PerfOS\\Performance',`
'SYSTEM\\CurrentControlSet\\Services\\PerfNet\\Performance',`
'SYSTEM\\CurrentControlSet\\Services\\PerfDisk\\Performance')

CLS
""
"Performance.Counter.Query.ps1"
"Querys Remote Registrys to verify that 'Disable Performance Counters' value is not set"
""

$SERVER = Read-Host "Enter Server Name"

ForEach($subkey in $keyname)
    {
      $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine",$SERVER)
      $key = $reg.OpenSubkey($subkey)
      $value = $key.GetValue('Disable Performance Counters')
      #$key.SetValue("Disable Performance Counters","0")
      
      IF($value -eq $Null)
        {""
        "Value Doesn't Exist"}
  
      "$SERVER $subkey $value"
      ""
      }