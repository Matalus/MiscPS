 $TESTCSV = Import-Csv \\vault\tech3\Scripts\Matt\movecsv.csv

 $REMAINING = $TESTCSV

 foreach($person in $TESTCSV)
 {
 $person | ft -AutoSize
 Start-Sleep -Seconds 5
 $REMAINING = $REMAINING | Where-Object { $_.Displayname -ne $Mailbox.DisplayName}
 $REMAINING | Export-Csv \\vault\tech3\Scripts\Matt\remaining.csv -Force
 Write-Host CSV Updated...
 Start-Sleep -Seconds 5}
 

 $TESTCSV = $TESTCSV | Where-Object { $_.Displayname -ne "Monica Zacarias"}
 $TESTCSV = $TESTCSV | Where-Object { $_.Displayname -ne "Zachary Jamieson"}
 $TESTCSV = $TESTCSV | Where-Object { $_.Displayname -ne "Zack Whites"}
 $TESTCSV = $TESTCSV | Where-Object { $_.Displayname -ne "Christina Zacarias"}

$REMAINING| Export-Csv \\vault\tech3\TESTCSV2.csv