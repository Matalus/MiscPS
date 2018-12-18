$ErrorActionPreference = "Stop"

#Define root dir
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

#Path to export to
$ExportPath = "$RunDir\ExportTest.xlsx"

#Require ImportExcel
Import-Module ImportExcel

#sample export data
"Getting Sample Data"
$Procs = Get-Process
$WMI = Get-WmiObject -list
$Services = Get-Service

#array of export data
$Tabs = @($Procs,$WMI,$Services)
#Counter for sheet naming
$Count = 0
ForEach($Tab in $Tabs){

   $Count++
   $WorkSheetName = "Sheet$Count"

   $ExportParams = @{
      Path          = $ExportPath
      WorkSheetName = $WorkSheetName
      AutoSize      = $true
      FreezeTopRow  = $true
      BoldTopRow    = $true
      TableStyle    = "Medium21"
      TableName     =  $WorkSheetName
      ClearSheet    = $true
   }
   "Exporting $WorkSheetName..."
   #Create XL Export object using ImportExcel with params and table style template
   $Tab | Select-Object * | Export-Excel @ExportParams
}


Invoke-Item $ExportPath
