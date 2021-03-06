$d = Get-Date -Format MM.dd.yyyy-HH.mm

Stop-Transcript
Start-Transcript \\vault\tech3\Scripts\Matt\logs\ExtraRegCrawler$d.txt
 Import-Module ActiveDirectory
 $SERVERS = Get-ADComputer -SearchBase "OU=Servers,DC=corpdomain,DC=COM" -Filter * | sort name | select name
 
 FOREACH($COMPUTER in $SERVERS)
 {$COMPUTER = $COMPUTER.name
 Write-Host $COMPUTER
 reg query \\$COMPUTER\hklm\SOFTWARE /s | Select-String -Pattern "attachmate"
 reg query \\$COMPUTER\hku /s | Select-String -Pattern "attachmate"
 }
 
 Stop-Transcript