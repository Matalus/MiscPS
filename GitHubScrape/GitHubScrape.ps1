
$RepoURL = "https://github.com/Powershell/PowerShell" #URL or GitHub Repo
$BasePrefix = "https://github.com" #raw prefix for downloads

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 #use TLS

#map root directory and create files directory if it doesn't exist
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$filedir = "$RunDir\Files"
if(!(test-path $filedir)){
  New-Item -ItemType Directory -Path $filedir
}
#parse directory page for file paths
$RepoHTMLParams = @{
   Uri             = $RepoURL
   UseBasicParsing = $true
}
$RepoHTML = Invoke-WebRequest @RepoHTMLParams

#get all clickable file link URLs
$RepoFiles = $RepoHTML.Links | Where-Object {
   $_.Class -eq "js-navigation-open"
}

$Count = 0
#loop through all files
ForEach ($File in $RepoFiles) {
   $Count++
   ""
   "$($Count): $($File.href)"
   #retrieve blob file page
   $BlobParams = @{
      Uri             = $BasePrefix + $File.href
      UseBasicParsing = $true
   }
   $BlobParams.Uri
   $Blob = Invoke-WebRequest @BlobParams
   #retrieve raw file links
   $RawURL = $Blob.links | Where-Object {
      $_.id -eq "raw-url"
   }
   #only run if raw-url links exist
   if ($RawURL) {
      $RawParams = @{
         Uri = $BasePrefix + $RawURL.href
      }
      $Raw = Invoke-WebRequest @RawParams
      $filename = Split-Path -leaf $RawURL.href
      $filepath = "$filedir\$filename"
      "Writing to: $filepath"
      $Raw.Content | set-content -path $filepath -Force
   }
   else {
      "No Raw URL Skipping"
   }
     
}


