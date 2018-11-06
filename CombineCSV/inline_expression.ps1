#demonstation of inline expressions

#Define Script Dir
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

#sample array
[array]$Array = Import-Csv -Path $RunDir\cities_by_pop.csv


#Pop Less than 1 Million
$Array | Format-Table State,City,Pop,@{Name="Greater than 2M"; Expression={if([int]$_.Pop -gt 2000000){"true"}else{"false"}};}

#Round to pop to 2 decimal places this time using N and E shorthand
$Array | Format-Table State,City,Pop,@{N="Pop Rounded(Million)";E={[math]::round(($_.Pop / 1000000),2)}}

#City is in california
$Array | Format-Table State,City,Pop,@{N="Is Californa";E={if($_.State -like "Cal*"){"true"}};}
