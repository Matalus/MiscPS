$TRAFFICDATA = Get-ChildItem '\\azccs\c$\Program Files (x86)\prairieFyre Software Inc\CCM\DataDirectory\Node_01\t*.txt' | `
sort LastWriteTime -Descending | select -First 1 | ?{$_.LastWriteTime -le (Get-Date).AddHours(+1) -and $_.Length -ne 0} | select name,@{Expression={ [math]::Round($_.Length /1MB, 2)};Label="Size"},LastWriteTime,FullName
CLS
IF($TRAFFICDATA -eq $null)
    {"True"}

ELSE
    {

            #HTML Table Header
        $html = “<style>”
        $html = $html + “BODY{background-color:white; font-family:Calibri;}”
        $html = $html + “TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}”
        $html = $html + “TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Slategray; font-size:14pt;}”
        $html = $html + “TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Gainsboro; font-size:12pt;}”
        $html = $html + “</style>”

            [string]$BODY = ""
            $BODY = $TRAFFICDATA | ConvertTo-Html -Head $html

            Send-MailMessage -To "Matt_Hamende@shamrockfoods.com" -From "winservice@shamrockfoods.com" -Body $BODY -BodyAsHtml -Subject "PF Data Check" -SmtpServer "OA.shamrockfoods.com"

            }