Add-PSSnapin Citrix* -ErrorAction SilentlyContinue
Add-PSSnapin Xen* -ErrorAction SilentlyContinue
#Connect-XenServer -Server AZXEN4 -Creds $Cred

Remove-Item '\\xsvc\c$\scripts\QFARM.csv' -Force -ErrorAction SilentlyContinue
Remove-Item '\\xsvc\c$\scripts\appquery.csv' -Force -ErrorAction SilentlyContinue

#Builds array of farm servers
$FARMSERVERS = Get-XAWorkerGroup | Get-XAWorkerGroupServer | select Servername,WorkerGroupName | sort Servername

#Queries each sever in array of farm servers
ForEach($VM in $FARMSERVERS)
    {

    $SERVER = $VM.ServerName
    $QFARM = Get-XAServerLoad -ServerName $SERVER
    IF($QFARM -eq $null)
        {
        $SERVER
       "Could not be contacted"
       "-------------------------------------------------------------------"
       #Saves output temporarily to CSV
       $VM | Export-Csv '\\xsvc\c$\scripts\QFARM.csv' -Append -NoTypeInformation
       }
    }

    #Disconnected Session Counter
    $DISCO = (Get-XASession | ?{$_.state -eq 'Disconnected'}).count

    $APPREPORT = $null
    #Application Availability Query
    $APPS =  Get-XAApplication | ?{ $_.Enabled -eq $true}
        ForEach($Application in $APPS)
            {
            $WG = Get-XAApplication -BrowserName $Application | Get-XAWorkerGroup | Get-XAServer
            IF($WG -eq $null)
                {
                 $APPQUERY = Get-XAApplication -BrowserName $Application | Get-XAServer | ?{$_.LogonMode -ne 'AllowLogOns'}
                 #$FULLPOOL = Get-XAApplication -BrowserName $Application | Get-XAServer
                }
                ELSE
                {
                $APPQUERY = Get-XAApplication -BrowserName $Application | Get-XAWorkerGroup | Get-XAServer | ?{$_.LogonMode -ne 'AllowLogOns'}
                #$FULLPOOL = Get-XAApplication -BrowserName $Application | Get-XAWorkerGroup | Get-XAServer
                }
                    IF($APPQUERY -ne $null)
                    {
                    "True"
                    $ARRAY = $APPQUERY | select ServerName,LogonMode,@{Expression={ $Application.BrowserName};Label="Application"}
                    ForEach($line in $ARRAY)
                    {
                    $obj = New-Object -TypeName PSObject
                    $obj | Add-Member -NotePropertyName "ServerName" -NotePropertyValue $line.ServerName
                    $obj | Add-Member -NotePropertyName "LogonMode" -NotePropertyValue $line.LogonMode
                    $obj | Add-Member -NotePropertyName "Application" -NotePropertyValue $line.Application
                    [Array]$APPREPORT += $obj
                    }
                    $APPREPORT
                    }
                    
            }
            

#Mail Variables
$To="matt_hamende@corpdomain.com"
$SMTP="OA.corpdomain.COM"
$FROM="winservice@corpdomain.com"
$SUBJECT="XenApp6 - FARM Availability Report"
[String]$BODY = ""

$BODY ='<Font size=4 face="calibri" color="black"><B>The Following Farm Servers are not reporting to QFARM</B></font>
<BR><BR><B><font face="calibri" color="red"> PLEASE INVESTIGATE</font> </B><BR><BR>'

#HTML Table Header
$html = “<style>”
$html = $html + “BODY{background-color:white; font-family:Calibri;}”
$html = $html + “TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}”
$html = $html + “TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Slategray; font-size:14pt;}”
$html = $html + “TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Gainsboro; font-size:12pt;}”
$html = $html + “</style>”

$CSV = Import-Csv '\\xsvc\c$\scripts\QFARM.csv'

$BODY += $CSV | ConvertTo-Html -Head $HTML

#Disabled Server Query displays count of disabled servers as well as the servers
$DISABLED = Get-XAServer| ?{$_.LogonMode -ne 'AllowLogOns'} | select ServerName,LogonMode

#Uptime Query
$SERVERS = $FARMSERVERS.ServerName
$d = Get-Date
$UPTIME = ForEach($Server in $SERVERS)
{
Write-Host $SERVER
Get-WmiObject -ComputerName $Server Win32_OperatingSystem -ErrorAction SilentlyContinue `
|?{($d - [Management.ManagementDateTimeConverter]::ToDateTime($_.LastBootUpTime)).Days -ge 7}
}


 
$BODY += '<BR><BR><Font size=4 face="calibri" color="black"><B>The Following Hosts have been up Past Their Reboot Threshold</B></font><BR>'
$BODY += $UPTIME | Select-Object @{Expression={$_.CsName};Label="Server"},`
@{Expression={((Get-Date) - [Management.ManagementDateTimeConverter]::ToDateTime($_.LastBootUpTime)).Days};Label="Days"},`
@{Expression={[Management.ManagementDateTimeConverter]::ToDateTime($_.LastBootUpTime)};Label="Last Boot on"} | sort "Last Boot on" | ConvertTo-Html -Head $HTML


$BODY +='<BR><BR><Font size=4 face="calibri" color="black"><B>Servers with Logons Disabled</B></font>
<BR><B><font face="calibri" color="red">'
$BODY += $DISABLED.Count
$BODY += "</font> </B>"
$BODY += $DISABLED | ConvertTo-Html -Head $HTML

#Server Load Query
$LOAD = Get-XAServerLoad | sort load -Descending | select -First 10 Servername,Load

$BODY +='<BR><BR><Font size=4 face="calibri" color="black"><B>Highest Load</B></font>
<BR><B><font face="calibri" color="red">'
$BODY += "</font> </B>"
$BODY += $LOAD | ConvertTo-Html -Head $HTML


$BODY +='<BR><BR><Font size=4 face="calibri" color="black"><B>Current Disconnected Session Count</B></font>
<BR><B><font face="calibri" color="red">'
$BODY += $DISCO 
$BODY += "</font> </B>"

#Top Ten Disconnected Sessions Query
$TOPTEN = Get-XASession | ?{$_.state -eq 'Disconnected' -and $_.accountname -notlike '*mis*'} | sort DisconnectTime | select -First 10 SessionID,AccountName,ServerName,Browsername,State,DisconnectTime

$BODY +='<BR><BR><Font size=4 face="calibri" color="black"><B>Top 10 Oldest Disconnected Sessions (Non-IS)</B></font>
<BR><B><font face="calibri" color="red">'
$BODY += "</font> </B>"
$BODY += $TOPTEN | ConvertTo-Html -Head $HTML


$BODY +='<BR><BR><Font size=4 face="calibri" color="black"><B>Applications with Disabled Servers</B></font>
<BR><B><font face="calibri" color="red">'
$BODY += "</font> </B>"
$BODY += $APPREPORT | sort Application | ConvertTo-Html -Head $HTML


#Emails Results
Send-MailMessage -To $TO -From $FROM -Subject $SUBJECT -Body $BODY -SmtpServer $SMTP -BodyAsHtml