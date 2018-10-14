$name = 48
$delay = 245
FOR(;;)
{
$rulename = "Rule$name"
$rulename
$delay
$time = New-TimeSpan -Minutes $delay
$subscription = (Get-SCOMNotificationSubscription -DisplayName "09 Server Admin CRITICAL > 50 mins")  | Select-Object -First 1
$criteria = $subscription.Configuration.Criteria
$group = $subscription.Configuration.MonitoringObjectGroupIds | select -ExpandProperty Guid
$subscriber = Get-SCOMNotificationSubscriber "Server Admin CRITICAL and WARNING Alerts"
$channel = Get-SCOMNotificationChannel -DisplayName "Server Admin CRITICAL"
Add-SCOMNotificationSubscription -Name $rulename -DisplayName "$name Server Admin CRITICAL > $delay mins" -Subscriber $subscriber -Channel $channel -Criteria $criteria -Delay $time -Description ""
$update = Get-SCOMNotificationSubscription -Name "Rule$name"
$update.Configuration.MonitoringObjectGroupIds.Add($group)
$update.Update()
$name = $name + 1
$delay = $delay + 5
IF($delay -ge 485)
{
"True"
BREAK
}
}

