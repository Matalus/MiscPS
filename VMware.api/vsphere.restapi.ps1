#Script for interfacing with vCenter API - requires PS Core 6.x and up

if($PSVersionTable.PSVersion.Major -lt 6){
   Write-Error "This script requires PS Core 6.x and up"
}

$vcenter = "vcenter.contoso.com"
if(!$cred){
   $cred = Get-Credential
}

#credentials for vcenter
$apiuser = $cred.UserName
$apipass = $cred.GetNetworkCredential().Password

#Auth URL
$BaseAuthURL = "https://$vcenter/rest/com/vmware/cis/"
$BaseURL = "https://$vcenter/rest/vcenter/"
$vCenterSessionURL = $BaseAuthURL + "session"
$Header = @{"Authorization" = "Basic " +
[System.Convert]::ToBase64String(
   [System.Text.Encoding]::UTF8.GetBytes(
      $apiuser + 
      ":" +
      $apipass
   )
)}

$SessionParams = @{
   Uri = "https://$vcenter/rest/com/vmware/cis/session"
   Method = "POST"
   Headers = $Header
   ContentType = "application/json"
   SkipCertificateCheck = $true
}
$SessionResponse = Invoke-RestMethod @SessionParams
if($SessionResponse){
   "vcenter-api-session-id: $($SessionResponse.value)"
}

$SessionHeader = @{'vmware-api-session-id' = $SessionResponse.value}

$VMListURL = $BaseURL + "resource-pool"

Try{
   $RestParams = @{
      Method = "GET"
      URI = $VMListURL
      TimeoutSec = 100
      Headers = $SessionHeader
      ContentType = 'application/json'
      SkipCertificateCheck = $true
   }
   $ResponseJSON = Invoke-RestMethod @RestParams
   "Result:"
   $ResponseJSON.value
}Catch{
   $_.Exception.ToString()
   $error[0] | Format-List -Force
}

