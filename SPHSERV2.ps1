﻿$TESTDIR = Test-Path \\cinnamon\$($ENV:UserName)\iSeries_Sessions
IF($TESTDIR -ne $true)
{New-Item -ItemType Directory -Path \\cinnamon\$($ENV:UserName)\iSeries_Sessions}

$TEST = Test-Path \\cinnamon\$($ENV:UserName)\iSeries_Sessions\sphserv2.ws
$KBTEST = Test-Path \\cinnamon\$($ENV:UserName)\iSeries_Sessions\Shamrock_KB.kmp

IF($TEST -ne $true)
{Copy-Item "\\userdata.corpdomain.com\entbpi$\IBM\sphserv2.ws" "\\cinnamon\$($ENV:UserName)\iSeries_Sessions"}


IF($KBTEST -ne $true)
{Copy-Item "\\userdata.corpdomain.com\entbpi$\IBM\Shamrock_KB.kmp" "\\cinnamon\$($ENV:UserName)\iSeries_Sessions"}

Invoke-Item \\cinnamon\$($ENV:UserName)\iSeries_Sessions\sphserv2.ws