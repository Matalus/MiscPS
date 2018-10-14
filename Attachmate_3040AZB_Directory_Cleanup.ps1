Stop-Transcript -ErrorAction SilentlyContinue

Start-Transcript \\vault\tech3\Scripts\Matt\logs\Attachmate_3040AZB_Folder_Delete.log

#$ErrorActionPreference = "SilentlyContinue"

$Shares = @(
"\\3040azb\rawdata$",
"\\3040azb\crossdep$")

foreach($Share in $Shares)
{
    $DIR = Get-ChildItem $Share
    ForEach($Profile in $DIR)

   {Write-Host (get-date) Scanning $Profile.PsPath.Replace("Microsoft.PowerShell.Core\FileSystem::","")...
    $MATCH = (Get-ChildItem -ErrorAction SilentlyContinue -Recurse $Profile.PSPath -filter attachmate).PsPath.Replace("Microsoft.PowerShell.Core\FileSystem::","") 
        IF($MATCH -ne $null)
        {
        $MATCH >> \\vault\tech3\Scripts\Matt\logs\3040AZB_Attachmate_Match.log
        Write-output "Deleting" >> \\vault\tech3\Scripts\Matt\logs\3040AZB_Attachmate_Match.log
        $MATCH | Remove-Item -Force -Recurse >> \\vault\tech3\Scripts\Matt\logs\3040AZB_Attachmate_Match.log
        Write-output "Running Follow up" >> \\vault\tech3\Scripts\Matt\logs\3040AZB_Attachmate_Match.log
        $MATCH = $null >> \\vault\tech3\Scripts\Matt\logs\3040AZB_Attachmate_Match.log
        $MATCH = (Get-ChildItem -ErrorAction SilentlyContinue -Recurse $Profile.PSPath -filter attachmate).PsPath.Replace("Microsoft.PowerShell.Core\FileSystem::","") >> \\vault\tech3\Scripts\Matt\logs\3040AZB_Attachmate_Match.log
        $MATCH >> \\vault\tech3\Scripts\Matt\logs\3040AZB_Attachmate_Match.log
        $MATCH = $null >> \\vault\tech3\Scripts\Matt\logs\3040AZB_Attachmate_Match.log
        Write-output "-----------------------------------------" >> \\vault\tech3\Scripts\Matt\logs\3040AZB_Attachmate_Match.log
        }
        ELSE
        {
        #Do Nothing
        }
    
    }
}

Stop-Transcript

