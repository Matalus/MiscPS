$TEST = @("Test1","Test2")

CLS

foreach($thing in $TEST)
{

$STOP = (Get-Date).Hour
    IF($STOP -ne 5)
    {Write-Host $thing}
    ELSE
    {
    Write-Host Outside Time Threshold Exiting
    BREAK
    }
}