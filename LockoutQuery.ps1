#LockoutQuery.ps1 created by Matt Hamende SFC 2014
#Queries AD for users that were recently locked out.
#Users the information from the user Query to Pull a small targeted sample of DC Security logs
#Identifies events that occured within the sample containing the affected users ID
#Sends email with results.
$LockedOut = $null
$LockedOut = Get-ADUser -Properties AccountLockoutTime,LastBadPasswordAttempt,BadPwdCount,LockedOut  -Filter * | ?{$_.AccountLockOutTime -ge (Get-Date).AddMinutes(-10) -and `
$_.BadPwdCount -ge 5 -and $_.Distinguishedname -notlike "*OU=External,DC=corpdomain,DC=com*" -and $_.name -notlike "iisuser"}
$LockedOut | ft name,samaccountname,LockedOut,AccountLockoutTime,BadPwdCount,LastBadPasswordAttempt
$DomainControllers = Get-ADDomainController -Filter *   
$results = $null 
ForEach($lockeduser in $LockedOut)
    {
    $lockedusername = $lockeduser.name
    ForEach($DC in $DomainControllers.name)
        {
        
        $starttime = $lockeduser.AccountLockoutTime.AddSeconds(-1)
        $endtime = $lockeduser.AccountLockoutTime.AddSeconds(1)
        $hash = $null
        $hash =  @{}
        $hash.Add("Logname", "security")
        $hash.Add("Starttime", $starttime)
        $hash.Add("Endtime", $endtime)
        "$lockedusername -  Locating Events between $starttime and $endtime on $DC..."
        $messagecriteria = $lockeduser.samaccountname
        $message = Get-WinEvent -ComputerName $DC -FilterHashtable $hash  | ?{$_.Message -like "*$messagecriteria*"}
        $message |ft @{Expression={$ExecutionContext.InvokeCommand.ExpandString($lockeduser.Name)};Label="Name"}, `
        @{Expression={$ExecutionContext.InvokeCommand.ExpandString($lockeduser.SamAccountName)};Label="SAMID"},machinename,TimeCreated,ID,message
        $hash.Clear()
        IF($message -ne $null)
            {
            ForEach($event in $message)
            {
            $eventxml = [xml]$event.ToXml()

            For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) {            
            # Append these as object properties            
            Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  $eventXML.Event.EventData.Data[$i].name -Value $eventXML.Event.EventData.Data[$i].'#text'            
            }
            $hostcomputer = $null
            $hostip = $null
            $hostip = $event.IpAddress.Replace("::ffff:","")            
            $hostcomputer = ([System.Net.Dns]::GetHostbyAddress($hostip)).HostName
            $IP = IF($event.IpAddress -ne $null){$hostcomputer+"|"+$hostip}
            #$event | ft * -Wrap

            $obj = New-Object -TypeName PSObject
                    $obj | Add-Member -NotePropertyName "Name" -NotePropertyValue $LockedUser.name
                    $obj | Add-Member -NotePropertyName "SamID" -NotePropertyValue $LockedUser.SamAccountName
                    $obj | Add-Member -NotePropertyName "DC" -NotePropertyValue $DC
                    $obj | Add-Member -NotePropertyName "TimeCreated" -NotePropertyValue $Event.TimeCreated
                    $obj | Add-Member -NotePropertyName "IP" -NotePropertyValue $IP
                    $obj | Add-Member -NotePropertyName "Event ID" -NotePropertyValue $event.ID
                    $obj | Add-Member -NotePropertyName "Message" -NotePropertyValue $event.message
                    [Array]$results += $obj
            }
                    
            }
        }
        "----------------------------------------------------------------------------------------------------------"
    
    }

    "Table of results"
    $results | ft
IF($results -ne $null)
{

#Mail Variables
$To="matt_hamende@corpdomain.com","Steve_Tollaksen@corpdomain.com","Miguel_Rivera@corpdomain.com","Aaron_Webster@corpdomain.com","Carmen_Sanchez@corpdomain.com","Don_Wenzl_III@corpdomain.com","Tom_Donaldson@corpdomain.com"
$SMTP="OA.corpdomain.COM"
$FROM="winservice@corpdomain.com"
$SUBJECT="AD - Account Lockout Alert"
[String]$BODY = ""

#HTML Table Header
$html = “<style>”
$html = $html + “BODY{background-color:white; font-family:Calibri;}”
$html = $html + “TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}”
$html = $html + “TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Slategray; font-size:14pt;}”
$html = $html + “TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:Gainsboro; font-size:12pt;}”
$html = $html + “</style>”

$BODY ='<Font size=4 face="calibri" color="black"><B>Recent Account Lockouts</B></font>
<BR><BR><B><font face="calibri" color="red">PLEASE INVESTIGATE</font> </B><BR><BR>'
$BODY += '<Font size=3 face="calibri" color="black"><B>Summary:</B></font>'
$BODY += $LockedOut | select name,samaccountname,LockedOut,AccountLockoutTime,BadPwdCount,LastBadPasswordAttempt | ConvertTo-Html -Head $html
$BODY += '<BR><BR><Font size=3 face="calibri" color="black"><B>Assocated Event Logs:</B></font>'
$BODY += $results | ConvertTo-Html -Head $HTML

Send-MailMessage -To $TO -From $FROM -Subject $SUBJECT -Body $BODY -SmtpServer $SMTP -BodyAsHtml
}