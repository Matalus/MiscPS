Stop-Transcript -ErrorAction SilentlyContinue

Start-Transcript \\vault\tech3\Scripts\Matt\logs\Attachmate_Folder_Delete.log

#$ErrorActionPreference = "SilentlyContinue"

$Shares = @("\\vault\appdata$",
"\\vault\library",
"\\vault\drivers",
"\\vault\itstorage$",
"\\vault\userdata$",
"\\3040aza\adminu$",
"\\3040aza\bladmin$",
"\\3040aza\hd",
"\\3040aza\useraz$",
"\\3040aza\profile$",
"\\3040aza\salesprofile$",
"\\3040aza\shared",
"\\3040azb\rawdata$",
"\\3040azb\crossdep$",
"\\3170aza\profile$",
"\\dendfs1\CitrixProfiles",
"\\dendfs1\ps4profiles",
"\\dendfs2\Denprofile\Denprofile",
"\\dendfs2\Profile\Profiles",
"\\phxdfs1\CitrixProfiles",
"\\phxdfs1\ps4profiles",
"\\3020coa\adminu$",
"\\3020coa\dataw1$",
"\\3020coa\cousers$",
"\\3020cob\cowinbackup$",
"\\3020cob\denprofiles$",
"\\3020cob\drazhelpdesk$")

foreach($Share in $Shares)
{
    $DIR = Get-ChildItem $Share
    ForEach($Profile in $DIR)

   {Write-Host (get-date) Scanning $Profile.PsPath.Replace("Microsoft.PowerShell.Core\FileSystem::","")...
    $MATCH = (Get-ChildItem -ErrorAction SilentlyContinue -Recurse $Profile.PSPath -filter attachmate).PsPath.Replace("Microsoft.PowerShell.Core\FileSystem::","") 
        IF($MATCH -ne $null)
        {
        $MATCH >> \\vault\tech3\Scripts\Matt\logs\Attachmate_Match.log
        Write-output "Deleting" >> \\vault\tech3\Scripts\Matt\logs\Attachmate_Match.log
        $MATCH | Remove-Item -Force -Recurse >> \\vault\tech3\Scripts\Matt\logs\Attachmate_Match.log
        Write-output "Running Follow up" >> \\vault\tech3\Scripts\Matt\logs\Attachmate_Match.log
        $MATCH = $null >> \\vault\tech3\Scripts\Matt\logs\Attachmate_Match.log
        $MATCH = (Get-ChildItem -ErrorAction SilentlyContinue -Recurse $Profile.PSPath -filter attachmate).PsPath.Replace("Microsoft.PowerShell.Core\FileSystem::","") >> \\vault\tech3\Scripts\Matt\logs\Attachmate_Match.log
        $MATCH >> \\vault\tech3\Scripts\Matt\logs\Attachmate_Match.log
        $MATCH = $null >> \\vault\tech3\Scripts\Matt\logs\Attachmate_Match.log
        Write-output "-----------------------------------------" >> \\vault\tech3\Scripts\Matt\logs\Attachmate_Match.log
        }
        ELSE
        {
        #Do Nothing
        }
    
    }
}

Stop-Transcript

