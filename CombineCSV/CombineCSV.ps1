

#Define ScriptDir
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Import Major Cities
[array]$Cities = Import-Csv $RunDir\cities_by_pop.csv -Encoding utf8
"Found : $($Cities.Count) rows in Cities by pop"

#Import State Capitals
[array]$Capitals = Import-Csv $RunDir\capital_cities.csv -Encoding utf8
"Found : $($Capitals.Count) rows in Capital Cities"

#empty array to append into
$Array = @()

#Merge Capital to State
ForEach($City in $Cities){
   #We look up the data we want to merge for each loop object
   $CapData = $Capitals | Where-Object {
      $_.State -eq $City.State
   } # This gets us the object containing the capital city data for the current state
   
   #creates new psobject and append properties
   $obj = [pscustomobject]@{
      State = $City.State
      Major_City = $City.City
      Major_Pop = $City.pop
      Capital_City = $CapData.Capital
      Capital_Pop = $CapData.Population
      Statehood = $CapData.Statehood
   }
   #Now that we created an object with our merged properties we append the array
   $Array += $obj #appends array
}

#display combined results
$Array | Format-Table #outputs array

#export as csv
$Array | Export-Csv -NoTypeInformation -Path $RunDir\Merged.csv -Force

Invoke-Item $RunDir\Merged.csv


