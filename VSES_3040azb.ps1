Import-Module DataONTAP
$query = $null
$count = $null
Connect-NaController 3040azb

$query = Get-NaSystemLog -MessageLog -StartTime (Get-Date).AddMinutes(-5) `
| ?{$_.message -like "*172.16.253.185*" -or $_.message -like "*172.16.253.206*" -or $_.message -like "*\\SF1WNAAVP0*"}

IF($query -ne $null)
{ "Not Null = True" 
    
    $count = $query.Count

    IF($count -ge 2)

    {
       

        #Mail Variables
        #$To="system_engineers@shamrockfoods.com"
        $To="Matt_Hamende@shamrockfoods.com","Steve_Tollaksen@shamrockfoods.com"
        $SMTP="OA.SHAMROCKFOODS.COM"
        $FROM="winservice@shamrockfoods.com"
        $SUBJECT="VSCAN Alert on 3040azb"
        $BODY = ""

        $BODY += “<font face=Calibri color=green size=5><h2>McAfee VSCAN Alert</h2></font>"
        $BODY += "<b><font face=Calibri color=black size=3>errors detected</font><br>"
        $BODY += "<font face=Calibri color=black size=3>ERROR COUNT = $count </font><br><br></b>"
       

        $html = “<style>”
        $html = $html + “BODY{background-color:white; font-family:Calibri;}”
        $html = $html + “TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}”
        $html = $html + “TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Slategray; font-size:14pt;}”
        $html = $html + “TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Gainsboro; font-size:12pt;}”
        $html = $html + “</style>”

        $BODY += $query | select TimeStamp,Source,Severity,Message | ConvertTo-Html -Head $html


        Send-MailMessage -To $TO -From $FROM -Subject $SUBJECT -Body $BODY -SmtpServer $SMTP -BodyAsHtml
        }
        

    }
    ELSE
        {$count
        "Below Threshold"}
