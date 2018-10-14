

$ARRAY = Get-MailboxDatabase -Identity "AZMAIL\Storage Group 6\Mailbox Database 6" | Get-Mailbox


$Count = 0
foreach($Mailbox in $ARRAY)
    {
    
    $Count++
    Write-Host $Count $Mailbox.Name

    Get-MailboxFolderStatistics -Identity $Mailbox | Where-Object { $_.FolderType -ne 'User Created' } | select identity,ItemsinFolderAndSubfolders | Export-Csv U:\MailboxFolderStats.csv -Append

    }