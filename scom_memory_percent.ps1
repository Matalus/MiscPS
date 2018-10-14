$API = New-Object -ComObject "MOM.ScriptAPI"
$BAG = $API.CreatePropertyBag()
$MEM=(Get-WmiObject -Class Win32_OperatingSystem)
$PERCENTFREE = 100 - ([int]((($MEM.TotalVisibleMemorySize - $MEM.FreePhysicalMemory) * 100)`
/$MEM.TotalVisibleMemorySize))
$BAG.AddValue("PerMemFree",$PERCENTFREE)
$BAG