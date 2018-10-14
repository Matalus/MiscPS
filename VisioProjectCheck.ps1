$WMI = Get-WmiObject Win32_Product | Where-Object { $_.name -like '*Visio*' -or $_.name -like '*Project*'}

$OBJ = New-Object PSObject

