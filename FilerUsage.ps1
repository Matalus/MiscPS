

Stop-Transcript -ErrorAction SilentlyContinue
$d = Get-Date -Format MM.dd.yyyy-HH.mm

Start-Transcript \\vault\tech3\Scripts\Matt\logs\FilerUsage$d.txt

CLS


Write-Host FilerCheck.ps1 -- compares current directory sizes against snapshots
Write-Host ""
Write-Host "Transcript Started - Script Will Log output to \\vault\tech3\Scripts\Matt\logs\FilerUsage$d.log"
Write-Host ""

ForEach($Folder in Get-ChildItem \\vault\userdata$\~snapshot\daily.0\azusers | Where {$_.PSisContainer -eq $True} | Sort-Object){

$UNC = ($Folder.PSPath).Split("::")[2]

ForEach($DIR in Get-ChildItem $UNC | Where {$_.PSisContainer -eq $True} | Sort-Object)
{
$CurrentDir = ($DIR.PSPath).Split("::")[2]

$LastWeek = $CurrentDir.Replace("~snapshot\daily.0", "~snapshot\daily.6")

Write-Host -------------------------------------------------------------------------------------
Write-Host "Current Week $CurrentDir --- "(Get-Date)
Write-Host "Last Week    $LastWeek --- " (Get-Date)
Write-Host ""

$Bytes= Get-ChildItem $CurrentDir -Recurse -ErrorAction "SilentlyContinue" | Where {$_.Length -ne $null} | Measure-Object -Property Length -Sum
$GB = [MATH]::Round(($Bytes.SUM / 1GB), 2)
Write-Host "Directory $DIR Currently contains "$($GB)GB" of Data"

$OldBytes = Get-ChildItem $LastWeek -Recurse -ErrorAction "SilentlyContinue" | Where {$_.Length -ne $null} | Measure-Object -Property Length -Sum
$OldGB = [MATH]::Round(($OldBytes.SUM / 1GB), 2)

$Diff = [MATH]::Round(($GB - $OldGB), 2)

#Write-host $DIR



Write-Host "Last Week $DIR Contained ........."$($OldGB)GB" of Data"
Write-Host "Difference of ........................"$($Diff)GB""
Write-Host ""

IF($Diff -ge 1)
{Write-Output -forecolor red "Directory $DIR has grown by "$($Diff)GB"" >> \\vault\Tech3\Scripts\Matt\logs\ExcessiveGrowth$d.log}

}
}
Stop-Transcript