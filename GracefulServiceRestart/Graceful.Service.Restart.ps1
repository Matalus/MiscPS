#Local Services Restart Script
#Restarts Services proactively gracefully in order, and verifies restart was successful.
#Matt Hamende IO DataCenters 2015

#Define Script Dir
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

#Check for / Create Log Dir
$LogDir = "$RunDir\logs"
if(!(test-path $LogDir)){
   New-Item -ItemType Directory -Path $LogDir
}

#cleans up old logs
Get-ChildItem $LogDir -Filter *log* | Where-Object {
   $_.LastWriteTime -le (Get-Date).AddDays(-5)
} | Remove-Item -Force -Confirm:$false

#log start time
$starttime = Get-Date
$d = Get-Date -Format MMddyyyyHHmmss #create log timestamp
$server = $env:COMPUTERNAME

Trap {Continue} Stop-Transcript # stop transcript service if already running
#Starts logging
$logfile = "$LogDir\$d--$server-log.txt"
$logtest = $logfile
Start-Transcript -Path $logfile

#Load Config
$Config = (Get-Content $RunDir\Config.json) -join "`n" | ConvertFrom-Json

#Sleeptimer to allow delay for service restart
Function Sleeptimer {
   foreach ($i in 1..5) {
      $remaining = New-TimeSpan -Seconds (5 - $i)
      #Write-Progress -Activity "Retrying in $remaining" -PercentComplete (($i / 5) *100)
      Start-Sleep -Seconds 1
   }
}
$ListAll = Get-Service

$TargetServices = $ListAll | Where-Object {
   $_.Name -in $Config.Services
}

#Create array of sorted objects
$StopOrder = @()
$Sort_Count = 0
ForEach($Service in $Config.Services){
   $Sort_Count++
   $CurrentService = $TargetServices | Where-Object{
      $_.Name -eq $Service
   }
   $CurrentService | Add-Member Sort_Order($Sort_Count) -Force
   $StopOrder += $CurrentService
}

#Reverse array for Start Order
$StartOrder = $StopOrder | Sort-Object Sort_Order -Descending

"Stop Order"
$stoporder | Format-Table DisplayName, Status, sort_order -AutoSize

"Start Order"
$startorder = $stoporder | Sort-Object Sort_Order -Descending
$startorder| Format-Table DisplayName, Status, sort_order -AutoSize

#Counter of failed service restarts, increments eachtime a service fails to restart successfully
$failcount = 0

"$(Get-Date) - Stopping All Services Gracefully..."
""

#Stop array loop
ForEach ($service in $stoporder.Name) {
   #Verifies that service is present
   $status = Get-Service $service -ErrorAction SilentlyContinue
   if ($status -eq $null) {
      #"$(get-date) - $service is not present on system"
   }else {
      "$(get-date) - Stopping $service..."
      #Stops Service
      $stop = stop-Service $service -force
   }
}
#END LOOP
""
"$(Get-Date) - All Services Should be Stopped at this point"
""
"Killing any hung services..."
""

#Safety measure to force kill hung services that didn't stop
$ALLSERVICES = Get-Service
$ALLSTOPPED = Foreach ($service in $stoporder) {
   $ALLSERVICES | Where-Object {
      $_.Name -eq $service.Name
   }
}

""
"$(Get-date) Querying Status from WMI"

ForEach ($service in $ALLSTOPPED) {
   $WMI = Get-WmiObject Win32_Service | Where-Object {
      $_.Name -eq $service.DisplayName
   }
   $WMI | Select-Object name, state
   if ($WMI.state -ne "stopped") {
      $PROC = $WMI.processid
      Write-Host -ForegroundColor Red "$($service.name) not stopped"
      "Force Killing $($WMI.pathname) PID=$PROC..."
      Get-Process -Id $PROC | Stop-Process -Force
      $WMI = Get-WmiObject Win32_Service | Where-Object {
         $_.Name -like $service
      }
      $WMI | Select-Object name, state
   }
}
""       
"$(Get-Date) - Starting All Services Gracefully..."
""

#Start array loop
ForEach ($service in $startorder) {
   #Verifies that service is present
   $status = Get-Service $service -ErrorAction SilentlyContinue
   if ($status -eq $null) {
      #"$(get-date) - $service is not present on system"
   }else {
      "$(get-date) - Starting $service..."
      #starts service
      Start-Service $service

      #starts timer to allow log to update post restart
      Sleeptimer
      #Scrapes System Event log for messages from the last minute
      $verify = Get-WinEvent -FilterHashtable @{Logname = "System"; Starttime = (Get-Date).AddMinutes(-$config.EventLogFilter)}
      #Long name for service as it would appear in the log
      $servicename = $status.DisplayName
      #"verify done" - DEBUG
      #Verifies presence of service stop message
      $verifystop = $verify | Where-Object {
         $_.id -eq 7036} | Where-Object {
             $_.message -like "*$servicename*stopped*"
         }
      #Verifies presence of service start message
      $verifystart = $verify | Where-Object {
         $_.id -eq 7036} | Where-Object {
            $_.message -like "*$servicename*running*"
         }

      $Currentstate = (Get-Service $service).Status
          
      #below logic reports if service restarted succesffully based on "Verify" values.
       
      #determine if service stopped
      if ($verifystop -ne $null) {
         "$(get-date) - $service stop successful"
         $stopstate = "Success"
      }else {
         "$(get-date) - $service stop failed"
         $stopstate = "Failed"
         #Increments Fail Count by 1
         $failcount++
      }
      
      #determine if service started
      if ($verifystart -ne $null) {
         "$(get-date) - $service start successful"
         $startstate = "Success"
      }else {
         "$(get-date) - $service start Failed"
         $startstate = "Failed"
         #Increments Fail Count by 1
         $failcount++
      }
      $ServiceState = [pscustomobject]@{
         TimeStamp = (Get-Date)
         "Service Name" = $servicename
         "Stop" = $stopstate
         "Start" = $startstate
         "Last State" = $Currentstate
      }

      #append data to report
      [ARRAY]$Report += $ServiceState
   }
            
}

"Failcount = $failcount"
$TEST = Test-Path "$RunDir\test.txt"
if ($TEST -eq $true) {
   $failcount++
}

""
#Get Status from WMI
"$(Get-date) Querying Status from WMI"
$WMIGET = Get-WmiObject -Class Win32_Service
$WMI = ForEach ($wmiobject in $startorder) {
   $WMIGET | Where-Object {
      $_.displayname -eq $wmiobject
   }
}
$WMI | Select-Object name, state
   
#calculate duration
$endtime = Get-Date
$duration = [Math]::Round((($endtime - $starttime).TotalSeconds), 2)
        
$starttime
$endtime
$duration

if ($failcount -ge 1) {

   #Queries Host Information to be displayed in subject of email.
   $IP = (Get-WmiObject win32_NetworkAdapterConfiguration | Where-Object {
      $_.IPAddress -ne $null -and 
      $_.DefaultIPGateway -ne $null
   }).IPAddress[0]
   $Hostname = $env:COMPUTERNAME
   $desc = (Get-WmiObject win32_OperatingSystem).Description

   $server = $Hostname + " (" + $IP + ")"
            
   $BODY = $null
   [String]$BODY = ""
   $BODY += ""

   $BODY = @"
            <Font size=4 face='segoe ui' color='Gray'>ServerName: $Hostname</font><br>
            <Font size=4 face='segoe ui' color='Gray'>IP Address: $IP</font><br>
            <Font size=4 face='segoe ui' color='Gray'>Description: $desc</font><br>
            <Font size=4 face='segoe ui' color='Gray'>Start Time: $starttime</font><br>
            <Font size=4 face='segoe ui' color='Gray'>End Time: $endtime</font><br>
            <Font size=4 face='segoe ui' color='Gray'>Duration(sec): $duration</font>
            <br><br>
            <Font size=3 face='segoe ui' color='black'>The following IO Services may be experiencing issues</B><BR><BR></font>
            <font face='segoe ui' color=Red size=4>
            Please Investigate<BR><BR>
    </font>
"@

   #HTML Table Header
   $html = @"
    <style>
    BODY{background-color:white; font-family:segoe ui;}
    TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
    TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:#f05a29; font-size:12pt;}
    TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:#414042; font-size:10pt; color:#ffffff}
    </style>
"@

   $BODY += $Report | ConvertTo-Html -Head $HTML
   $BODY = $BODY.Replace('<td>Success</td>', '<td style="background-color:Green;">Success</td>')
   $BODY = $BODY.Replace('<td>Failed</td>', '<td style="background-color:Red;">Failed</td>')


   #Dump Error Buffer
   "Errors -------------------------------------------------"
   #$Error

   $MailParams = @{
      To = $Config.Email.To
      From = $Config.Email.From
      SmtpServer = $Config.Email.Smtp
      Subject = "Service Restart Error on $Hostname"
      BodyAsHtml = $True
      Body = $BODY
      Attachements = $logfile
      Port = $Config.Email.Port
      UseSsl = $true
      Credential = if($Config.Email.Password -lt 1 -or $Config.Email.Password -eq $Null){
         Get-Crential
      }else{
         New-Object System.Net.NetworkCredential(
            $Config.Email.Username,
            $Config.Email.Password
         )
      }
   }


   #Stops Logging.            
   #Trap {Continue} Stop-Transcript
   Stop-Transcript

   $logfile
   $logtest
   "Sending Error Email"
   Send-MailMessage @MailParams
            
}

