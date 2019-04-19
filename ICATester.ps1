
Import-Module PSTerminalServices -ErrorAction SilentlyContinue
set winrm/config/winrs @{MaxMemoryPerShellMB="<4096"} 
Unregister-Event *

Function Sleeptimer
{
foreach($i in 1..5){$remaining = New-TimeSpan -Seconds (5 - $i)
Write-Progress -Activity "Retrying in $remaining" -PercentComplete (($i / 5) *100)
Start-Sleep -Seconds 1}
}

$xdaz = Get-Content \\vault\tech3\Scripts\Matt\xen.txt
#$xdaz = "xdaz05"
"IcaTester.ps1 - tests Citrix ICA connections using an automated loop"
"Created by - Matt Hamende SFC 2014"
""
$user = Read-Host -Prompt "Enter Username"
$passwordsecure = Read-Host -Prompt "Enter Password" -AsSecureString
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Passwordsecure))
Get-EventSubscriber | Unregister-Event
Get-Job | Remove-Job -Force
ForEach($server in $xdaz)
{
[System.Reflection.Assembly]::LoadFile("C:\Program Files (x86)\Citrix\ICA Client\WfIcaLib.dll")
$ICA = New-Object WFICALib.ICAClientClass
$ICA.Address = $server
$ICA.Application = ""
$ICA.Username = $user
$ICA.SetProp("Password",$password)
$ICA.Domain = "corpdomain"
$ICA.Launch = $true
$ICA.SetProp("Ispassthru",$true)
$ICA.OutputMode = [WFICALib.OutputMode]::OutputModeNormal
$ICA.DesiredColor = [WFICALib.ICAColorDepth]::Color16bit
$ICA.DesiredHRes = 1024
$ICA.DesiredVRes = 768
$ICA.Connect()

""
Write-Host -ForegroundColor cyan -BackgroundColor DarkGray "$(Get-Date -format G) - Testing Connection to $server..."
$session = $null
sleeptimer 
$session = Get-TSSession -ComputerName $server | ?{$_.UserName -eq $user -and $_.WindowStationName -like "*ICA-TCP*"}
IF($session -ne $null)
{write-host -foregroundcolor green "$(Get-Date -format G) - $server connection ok"
$session | ft -autosize 
IF($session -ne $null){"$(Get-Date -format G) - $server session found disconnecting..."
  Do{ write-host -foregroundcolor yellow "$(Get-Date -format G) - Waiting for Session to Disconnect"
      $session | Stop-TSSession -Force
      Start-Sleep -Seconds 2
      $session = Get-TSSession -ComputerName $server | ?{$_.UserName -eq $user -and $_.WindowStationName -like "*ICA-TCP*"}
    } Until ($session -eq $null) }
}
ELSE
{
    
    write-host -foregroundcolor yellow "$(Get-Date -format G) - Retrying in 10 seconds..."
    sleeptimer
    $session = Get-TSSession -ComputerName $server | ?{$_.UserName -eq $user -and $_.WindowStationName -like "*ICA-TCP*"}
    IF($session -ne $null)
    {write-host -foregroundcolor green "$(Get-Date -format G) - $server connection ok"
    $session | ft -autosize
    IF($session -ne $null){"$(Get-Date -format G) - $server session found disconnecting..."
    Do{ write-host -foregroundcolor yellow "$(Get-Date -format G) - Waiting for Session to Disconnect"
        $session | Stop-TSSession -Force
      Start-Sleep -Seconds 2
      $session = Get-TSSession -ComputerName $server | ?{$_.UserName -eq $user -and $_.WindowStationName -like "*ICA-TCP*"}
    } Until ($session -eq $null)}
    }
    ELSE
        {write-host -foregroundcolor yellow "$(Get-Date -format G) - Retrying in 10 seconds..."
        sleeptimer
        $session = Get-TSSession -ComputerName $server | ?{$_.UserName -eq $user -and $_.WindowStationName -like "*ICA-TCP*"}
        IF($session -ne $null)
        {write-host -foregroundcolor green "$(Get-Date -format G) - $server connection ok"
        $session | ft -autosize
        IF($session -ne $null){"$(Get-Date -format G) - $server session found disconnecting..."
        Do{ write-host -foregroundcolor yellow "$(Get-Date -format G) - Waiting for Session to Disconnect"
            $session | Stop-TSSession -Force
            Start-Sleep -Seconds 2
            $session = Get-TSSession -ComputerName $server | ?{$_.UserName -eq $user -and $_.WindowStationName -like "*ICA-TCP*"}
            } Until ($session -eq $null)}
        }
        ELSE{Write-Host -ForegroundColor Red "$(Get-Date -format G) - $server Connection Failed!!!"
        }

    }
}
"--------------------------------------------------------------"
}

