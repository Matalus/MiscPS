$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"

$d = (get-date -format MMddyyy_HHmmtt) 

Start-Transcript -path \\vault\tech3\scripts\matt\logs\ExchangeLogCounter_$d.txt  -append

#Mail Variables
$To="ServerAdmins@shamrockfoods.com"
$SMTP="OA.SHAMROCKFOODS.COM"
$FROM="winservice@shamrockfoods.com"
$Subject = "Exchange Log Counter"

$logs1="\\azmail1\m$\logs1\SG1logs"
$logs2="\\azmail1\m$\logs2\SG2logs"
$logs3="\\azmail1\m$\logs3\SG3logs"
$logs4="\\azmail1\m$\logs4\SG4logs"
$logs5="\\azmail1\m$\logs5\SG5logs"
$logs6="\\azmail1\m$\logs6\SG6logs"
$logs7="\\azmail1\m$\logs7\SG7logs"
$logs8="\\azmail1\m$\logs8\SG8logs"
$logs9="\\azmail1\m$\logs9\SG9logs"
$logs11="\\azmail1\m$\logs11\SG11logs"
$logs12="\\azmail1\m$\logs12\SG12logs"
$logs13="\\azmail1\m$\logs13\SG13logs"
$logs14="\\azmail1\m$\logs14\SG14logs"
$logs15="\\azmail1\m$\logs15\SG15logs"
$logs16="\\azmail1\m$\logs16\SG16logs"
$logs17="\\azmail1\m$\logs17\SG17logs"
$logs18="\\azmail1\m$\logs18\SG18logs"
$logs19="\\azmail1\m$\logs19\SG19logs"


$count1=(Get-ChildItem $logs1).count
$count2=(Get-ChildItem $logs2).count
$count3=(Get-ChildItem $logs3).count
$count4=(Get-ChildItem $logs4).count
$count5=(Get-ChildItem $logs5).count
$count6=(Get-ChildItem $logs6).count
$count7=(Get-ChildItem $logs7).count
$count8=(Get-ChildItem $logs8).count
$count9=(Get-ChildItem $logs9).count
$count11=(Get-ChildItem $logs11).count
$count12=(Get-ChildItem $logs12).count
$count13=(Get-ChildItem $logs13).count
$count14=(Get-ChildItem $logs14).count
$count15=(Get-ChildItem $logs15).count
$count16=(Get-ChildItem $logs16).count
$count17=(Get-ChildItem $logs17).count
$count18=(Get-ChildItem $logs18).count
$count19=(Get-ChildItem $logs19).count

Write-Host "NOTE: Log Truncation Failures will cause log directories to back up"
Write-Host ""
write-host $logs1     $count1
write-host $logs2     $count2
write-host $logs3     $count3
write-host $logs4     $count4
write-host $logs5     $count5
write-host $logs6     $count6
write-host $logs7     $count7
write-host $logs8     $count8
write-host $logs9     $count9
write-host $logs11    $count11
write-host $logs12    $count12
write-host $logs13    $count13
write-host $logs14    $count14
write-host $logs15    $count15
write-host $logs16    $count16
write-host $logs17    $count17
write-host $logs18    $count18
write-host $logs19    $count19

Stop-Transcript

$BODY = Get-Content \\vault\tech3\scripts\matt\logs\ExchangeLogCounter_$d.txt | Out-String -Width 8000

Send-MailMessage -To $TO -From $FROM -Subject $SUBJECT -Body $BODY -SmtpServer $SMTP