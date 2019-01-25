Import-Module DataONTAP
$query = $null
$count = $null
Connect-NaController 3040aza

$query = Get-NaSystemLog -MessageLog -StartTime (Get-Date).AddMinutes(-5) `
| ?{$_.message -like "*fpolicy*" -and $_.eventtype -notlike "*connecting.successful*"`
 -and $_.eventtype -notlike "*disconnectmissing*" -and $_.eventtype -notlike "*completionrequestlost*"`
  -and $_.eventtype -notlike "*requestto*" -and $_.eventtype -notlike "*droppedconn*"}

IF($query -ne $null)
{ "Not Null = True" 
    
    $count = $query.Count

    IF($count -ge 5)

    {
        #Disable-NaFpolicy
        "FPOLICY Disabled"

        #Mail Variables
        $To="system_engineers@corpdomain.com"
        #$To="Matt_Hamende@corpdomain.com"
        $SMTP="OA.corpdomain.COM"
        $FROM="winservice@corpdomain.com"
        $SUBJECT="Filer FPOLICY Alert on 3040azb"
        $BODY = ""

        $BODY += “<font face=Calibri color=green size=5><h2>FPOLICY error threshold has been exceeded</h2></font>"
        $BODY += "<b><font face=Calibri color=black size=3>FPOLICY has been disabled on 3040azb</font><br>"
        $BODY += "<font face=Calibri color=black size=3>ERROR COUNT = $count </font><br><br></b>"
       

        $html = “<style>”
        $html = $html + “BODY{background-color:white; font-family:Calibri;}”
        $html = $html + “TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}”
        $html = $html + “TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Slategray; font-size:14pt;}”
        $html = $html + “TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Gainsboro; font-size:12pt;}”
        $html = $html + “</style>”

        $BODY += $query | select TimeStamp,Source,Severity,Message | ConvertTo-Html -Head $html


        Send-MailMessage -To $TO -From $FROM -Subject $SUBJECT -Body $BODY -SmtpServer $SMTP -BodyAsHtml -cc "Danny_Vasquez@corpdomain.com"
        }
        

    }
    ELSE
        {$count
        "Below Threshold"}
