Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin

$SG = Get-StorageGroup | Where-Object { $_.name -notlike '*journal*' -and $_.name -notlike '*Public*'}
$TABLE = $null
ForEach($PATH in $SG)
    {
    
    $LOGPATH = ($PATH.LogFolderPath.PathName).Replace("M:\","\\AZMAIL\M$\")
    
    $LOGCOUNT = (Get-ChildItem $LOGPATH).count
    $STATS = New-Object PSObject
    $STATS | Add-Member -MemberType NoteProperty -Name "Log Path" -Value $LOGPATH
    $STATS | Add-Member -MemberType NoteProperty -Name "Log Count" -Value $LOGCOUNT

    [array]$TABLE += $STATS
    }
    $TABLE

    $html = “<style>”
$html = $html + “BODY{background-color:white; font-family:Calibri;}”
$html = $html + “TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}”
$html = $html + “TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Slategray; font-size:14pt;}”
$html = $html + “TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Gainsboro; font-size:12pt;}”
$html = $html + “</style>”

#Mail Variables
$To="ServerAdmins@shamrockfoods.com"
$SMTP="OA.SHAMROCKFOODS.COM"
$FROM="winservice@shamrockfoods.com"
$Subject = "Exchange Log Counter"

[string]$BODY = $TABLE | ConvertTo-Html -Head $html

Send-MailMessage -To $TO -From $FROM -Subject $SUBJECT -Body $BODY -SmtpServer $SMTP -BodyAsHtml