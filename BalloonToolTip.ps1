
Function BalloonTip ($Text,$Title,$Icon){
    Add-Type -AssemblyName System.Windows.Forms

    if (!$script:balloonToolTip){
        $script:balloonToolTip = New-Object System.Windows.Forms.NotifyIcon
    }

    #Define path
    $path = Get-Process -Id $pid | Select-Object -ExpandProperty Path

    #Set Properties
    $balloonToolTip.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $balloonToolTip.BalloonTipIcon = $icon
    $balloonToolTip.BalloonTipText = $Text
    $balloonToolTip.BalloonTipTitle = $Title
    $balloonToolTip.Visible = $true

    #Show Balloon Tool Tip
    $balloonToolTip.ShowBalloonTip(2000)
}

BalloonTip -Text "Hello World" -Title "Test" -Icon "info"