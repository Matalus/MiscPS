# Demonstration of speed doing lookups against multiple properties using index string and hashtables.
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
$measure = Measure-Command {
   [array]$WorldCities = (get-Content "$RunDir\WorldCities.json") -join "`n" | ConvertFrom-Json
}
Write-Host -BackgroundColor DarkGray -ForegroundColor White "Loaded $($WorldCities.Count) Cities into memory in $([math]::round($measure.TotalMilliseconds,2))ms"

Log "Building Hashtable" "Yellow"
$CityHash = @{ } #Declare new hashtable

#This can be one lined but I'll include long form for easier learning
$measure = Measure-Command {
   ForEach ($city in $WorldCities) {
      #Hasthables can only have unique keys so you need to always check if a key already exists before adding a key
      $key = "$($city.Name)|$($city.country)|$($city.lat)|$($city.lng)"
      #if not containskey add City Name as Key and full Object as Value
      if (!$CityHash.ContainsKey($key)) {
         #if not contains add key and value
         $CityHash.Add($key, $city) # I add my unique key string as an index and the full item as value
      }
   }
}

$CityStringIndex = $CityHash.Keys

Log "$($WorldCities.Count) Key Values pairs added to hashtable in $([math]::round($measure.TotalMilliseconds,2))ms" "Green"; "" #display results and time

For (; ; ) {
   #Start Infinite Search Loop
   $Results = $null
   Log "Prepare to behold the power of hashtables and Regex!!!" "Magenta" ; ""
   $SearchString = Read-Host -Prompt "Enter Search String"

   if ($SearchString -and $SearchString.Length -ge 2) { #validate input so only search on criteria
      $measure = Measure-Command {
         Log "Searching..."
         [array]$Matches = $CityStringIndex -match $SearchString

         $Results = @()
         if ($Matches) {
            ForEach ($Match in $Matches) {
               if ($CityHash.ContainsKey($Match)) {
                  $Results += $CityHash[$Match]
               }
            } 
         }
      }
   }else{
      Write-Warning "The minimum Search String Length is 2 - Please Try Again"
   }

   Log "Found: $($Results.Count) Matches in $([math]::round($measure.TotalMilliseconds,2))ms" "Cyan"; #display results and time

   $Results | Format-Table -AutoSize
}



