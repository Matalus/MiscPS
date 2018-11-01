
#Set Script Directory
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

#Load file
$params = (Get-Content $RunDir\params.json) -join "`n" | ConvertFrom-Json

#Display Params
$params | Format-List