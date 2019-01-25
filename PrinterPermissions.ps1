
Stop-Transcript -ErrorAction "SilentlyContinue"
Start-Transcript "\\vault\tech3\Scripts\Matt\logs\PrinterPermissionsLog2.log" -Append

$PRINTERS = (Get-WmiObject Win32_Printer)

foreach($PRINTER in $PRINTERS)
{$Server = $PRINTER.SystemName
 $PrinterName = $PRINTER.name
Write-Host \\$Server\$PrinterName 
Invoke-Command -AllowRedirection {subinacl.exe /printer \\$Server\$PrinterName /Grant=corpdomain\techsupport=F}
}
Stop-Transcript