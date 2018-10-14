$snapinfodir = ((Get-ChildItem \\azmail\m$\logs* | Get-ChildItem | ?{$_.name -like 'SME*' -and $_.PSisContainer -eq $true}).FullName) | Get-ChildItem | Get-ChildItem | Get-ChildItem | select Fullname


$QUERY = $snapinfodir | where { $_.Fullname -notlike '*xml*' -and $_.FullName -notlike '*.sme'}

foreach($DIR in $QUERY)
    {$DIR.FullName
    Remove-Item $DIR.FullName -Recurse -Force -ErrorAction SilentlyContinue }

    $snapinfodir = ((Get-ChildItem \\azmail\m$\logs* | Get-ChildItem | ?{$_.name -like 'SME*' -and $_.PSisContainer -eq $true}).FullName) | Get-ChildItem | Get-ChildItem | Get-ChildItem | select Fullname

$snapinfodir

    