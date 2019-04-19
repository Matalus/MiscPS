$Servers = @("ps4az1","ps4az2","ps4az4","ps4co1","ps4co2","ps4co3","ps4co4")
$RESULTS = $null
foreach($ServerName in $Servers)
    {
    $ServerName
    $queryResults = (qwinsta /server:$ServerName | foreach { (($_.trim() -replace “\s+”,”,”))} | ConvertFrom-Csv) | ?{$_.ID -like "Listen" -and $_.SessionName -like "ica-tcp"}

    
    
    IF($queryResults -ne $null)
        { 
        "True"
        }
        ELSE
        {
        $test = Test-Connection -Count 1 -ComputerName $ServerName
        IF($test -eq $null){$PING = "Failed"}ELSE{$PING = "Success"}
        $DOWN = New-Object psobject 
        $DOWN | Add-Member -NotePropertyName "Server" -NotePropertyValue $ServerName
        $DOWN | Add-Member -NotePropertyName "Ping" -NotePropertyValue $PING
        [ARRAY]$RESULTS += $DOWN
        
        } 

    }
    CLS
    "Servers in Error"
    $RESULTS

IF($RESULTS -ne $null)

    {
    #Mail Variables
    $To="system_engineers@corpdomain.com"
    $SMTP="OA.corpdomain.COM"
    $FROM="winservice@corpdomain.com"
    $SUBJECT="XenGateway ICA Listener Alert"
    [String]$BODY = ""

    $BODY ='<Font size=4 face="calibri" color="black"><B>The Following XenGateway Servers may be experiencing issues</B></font>
    <BR><BR><B><font face="calibri" color="red"> PLEASE INVESTIGATE</font> </B><BR><BR>'

    #HTML Table Header
    $html = “<style>”
    $html = $html + “BODY{background-color:white; font-family:Calibri;}”
    $html = $html + “TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}”
    $html = $html + “TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Slategray; font-size:14pt;}”
    $html = $html + “TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Gainsboro; font-size:12pt;}”
    $html = $html + “</style>”

    $BODY += $RESULTS | ConvertTo-Html -Head $HTML

    $BODY += 
    $BODY ='<Font size=4 face="calibri" color="black"><B><br><br>Steps to Try</B></font>
    <BR><BR><B><font face="calibri" color="black">1. use "rwinsta ica-tcp /server:#servername#" to restart the listener<br>2. restart the "Independent Management Architecture (IMASERVICE)" Service<br>3. Reboot the Server (Verify users are logged off)</font> </B><BR><BR>'

    Send-MailMessage -To $TO -From $FROM -Subject $SUBJECT -Body $BODY -SmtpServer $SMTP -BodyAsHtml
    }
