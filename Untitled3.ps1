

$TEST = Test-Path -Path '\\vault\tech3\Scripts\Matt\stop.txt'

IF($TEST -eq 'True')
{Write-Host File Found Exiting...
Remove-Item -Path \\vault\tech3\Scripts\Matt\stop.txt
Break
}
ELSE
{Write-Host Not Found}