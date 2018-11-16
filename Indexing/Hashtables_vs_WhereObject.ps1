# Demonstration of speed difference between using Where-Object vs Hashtable indexing with large arrays
# Matt Hamende 2018 https://github.com/Matalus

# Define Root Dir
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

#Simple Log function
#Generic Logging function --
Function Log($message, $color) {
   if ($color) {
       Write-Host -ForegroundColor $color "$(Get-Date -Format u) | $message"
   }
   else {
       "$(Get-Date -Format u) | $message"
   }
}

#Load Cites from file and convert from JSON to PSobject array
Log "Loading City Data" "Yellow"
$measure = Measure-Command{
   [array]$WorldCities = (get-Content "$RunDir\WorldCities.json") -join "`n" | ConvertFrom-Json
}
Write-Host -BackgroundColor DarkGray -ForegroundColor White "Loaded $($WorldCities.Count) Cities into memory in $([math]::round($measure.TotalMilliseconds,2))ms"
$x = Read-Host -Prompt "Press Enter to Start Demo"
# PSObject array of Cities to match against
# one-liner for generating the data
<# 
$WorldCities | Where-Object {$_.Name -in ("London","Paris","New York City","Tokyo")} | % {"[pscustomobject]@{Name='$($_.Name)'; Country='$($_.Country)'; lat=$($_.lat); lng=$($_.lng)},"}
#>
   $LookupCities = @(
   [pscustomobject]@{country='FR'; name='Paris'; lat=48.85341; lng=2.3488},
   [pscustomobject]@{country='GB'; name='London'; lat=51.50853; lng=-0.12574},
   [pscustomobject]@{country='JP'; name='Tokyo'; lat=35.6895; lng=139.69171},
   [pscustomobject]@{country='US'; name='New York City'; lat=40.71427; lng=-74.00597}
)
Log " + Lookup Data Loaded" "Green"
$LookupCities | Format-Table

Log "Looking up $($LookupCities.Count) Cities with Where-Object" "Magenta";""

#Loop through cities with Where-Object
ForEach($city in $LookupCities){
   Log "Looking up $($city.name)" "Yellow"
   $measure = Measure-Command {
   #lookup by city and country since some city names are redundant
      $lookup = $WorldCities | Where-Object { 
         $_.Name     -eq $city.Name -and
         $_.Country  -eq $City.Country -and
         $_.lat      -eq $city.lat -and
         $_.lng      -eq $city.lng
      }
   }  
   Log " + Found: $($lookup.Name) in $([math]::round($measure.TotalMilliseconds,2))ms $($lookup)" "Green" #display results and time
}
""
Log "Looking up $($LookupCities.Count) Cities with Hashtable Indexing" "Magenta" ;""

Log "Building Hashtable" "Yellow"
$CityHash = @{} #Declare new hashtable

#This can be one lined but I'll include long form for easier learning
$measure = Measure-Command{
   ForEach($city in $WorldCities){
      #Hasthables can only have unique keys so you need to always check if a key already exists before adding a key
      $key = "$($city.Name)|$($city.country)|$($city.lat)|$($city.lng)"
      #if not containskey add City Name as Key and full Object as Value
      if(!$CityHash.ContainsKey($key)){
         #if not contains add key and value
         $CityHash.Add($key,$city) # I add my unique key string as an index and the full item as value
      }
   }
}
Log "$($WorldCities.Count) Key Values pairs added to hashtable in $([math]::round($measure.TotalMilliseconds,2))ms" "Green";"" #display results and time

ForEach($City in $LookupCities){
   Log "Looking up $($city.name)" "Yellow"
      $measure = Measure-Command {
      $key = "$($city.Name)|$($city.country)|$($city.lat)|$($city.lng)"

      if($CityHash.ContainsKey($key)){ #confirm that Hashtable contains key
         #if contains key match value on index
         $lookup = $CityHash[$key] #index into hashtable
      }
   }  
   Log " + Found: $($lookup.Name) in $([math]::round($measure.TotalMilliseconds,2))ms $($lookup)" "Green"; #display results and time
}



