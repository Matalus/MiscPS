&"$env:WINDIR\syswow64\windowspowershell\v1.0\powershell.exe"

$xdaz = Get-Content \\vault\tech3\Scripts\Matt\xen.txt
$user = Read-Host -Prompt "Enter Username"
$password = Read-Host -Prompt "Enter Password"
ForEach($server in $xdaz)
{
[System.Reflection.Assembly]::LoadFile("C:\Program Files (x86)\Citrix\ICA Client\WfIcaLib.dll")
$ICA = New-Object WFICALib.ICAClientClass
$ICA.Address = $server
$ICA.Application = ""
$ICA.Username = $user
$ICA.SetProp("Password",$password)
$ICA.Domain = "corpdomain"
$ICA.Launch = $true
$ICA.SetProp("Ispassthru",$true)
$ICA.OutputMode = [WFICALib.OutputMode]::OutputModeNormal
$ICA.DesiredColor = [WFICALib.ICAColorDepth]::Color16bit
$ICA.DesiredHRes = 1024
$ICA.DesiredVRes = 768
$ICA.Connect()
}