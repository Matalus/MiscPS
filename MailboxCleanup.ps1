Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin -ErrorAction SilentlyContinue

$STARTDATE = ((Get-Date).AddYears(-10)).ToShortDateString()
$ENDDATE = ((Get-Date).Adddays(-20)).ToShortDateString()

$DIR = @("\Inbox\Purges","\Inbox\SCOM","\Inbox\SCOM\Warning","\Inbox\BB","\Inbox\SQL Idera","\B2B","\Inbox\PAGES","\Inbox\CCD","\Inbox\Oracle","\Inbox\root","\Inbox\SE Checks","\Deleted Items")

foreach($FOLDER in $DIR)
    {
    Get-Date
    $FOLDER
    Export-Mailbox -Identity "Matt Hamende" -IncludeFolders $FOLDER  -EndDate $ENDDATE -DeleteContent -DeleteAssociatedMessages -Confirm:$false | ft MoveStage,AssociatedMessagesDeleted,StandardMessagesDeleted -autosize
    }