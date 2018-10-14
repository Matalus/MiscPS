$user = Read-Host -Prompt "Enter Common Name of User:"

Get-CsUser -Identity $USER | Move-CsLegacyUser -Target lyncpool001.shamrockfoods.com -Confirm:$false